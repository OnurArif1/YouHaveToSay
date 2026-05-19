import axios, { type AxiosError } from 'axios'
import type { ApiErrorBody } from '@/types/backoffice'

const baseURL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5106'

export const apiClient = axios.create({
  baseURL,
  headers: { 'Content-Type': 'application/json' },
})

let onUnauthorized: (() => void) | null = null
let onForbidden: ((message: string) => void) | null = null

export function setAuthHandlers(handlers: {
  onUnauthorized: () => void
  onForbidden: (message: string) => void
}) {
  onUnauthorized = handlers.onUnauthorized
  onForbidden = handlers.onForbidden
}

export function setAuthToken(token: string | null) {
  if (token) {
    apiClient.defaults.headers.common.Authorization = `Bearer ${token}`
  } else {
    delete apiClient.defaults.headers.common.Authorization
  }
}

apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiErrorBody>) => {
    const status = error.response?.status
    const message = error.response?.data?.message ?? 'Bir hata oluştu.'

    if (status === 401) {
      onUnauthorized?.()
    } else if (status === 403) {
      onForbidden?.(message)
    }

    return Promise.reject(error)
  },
)

export function getErrorMessage(error: unknown): string {
  if (axios.isAxiosError<ApiErrorBody>(error)) {
    return error.response?.data?.message ?? error.message
  }
  if (error instanceof Error) {
    return error.message
  }
  return 'Beklenmeyen bir hata oluştu.'
}
