import { apiClient } from './apiClient'
import type {
  BackofficeComparisonDetail,
  BackofficeComparisonListItem,
  BackofficeDashboard,
  BackofficePagedResponse,
  BackofficeUsersSummary,
  ComparisonResult,
  ComparisonsQuery,
  CreateComparisonRequest,
  UpdateComparisonRequest,
} from '@/types/backoffice'

export const backofficeApi = {
  getDashboard() {
    return apiClient.get<BackofficeDashboard>('/api/backoffice/dashboard')
  },

  getComparisons(query: ComparisonsQuery = {}) {
    return apiClient.get<BackofficePagedResponse<BackofficeComparisonListItem>>(
      '/api/backoffice/comparisons',
      { params: query },
    )
  },

  getCategories() {
    return apiClient.get<string[]>('/api/backoffice/comparisons/categories')
  },

  getComparisonDetail(id: string) {
    return apiClient.get<BackofficeComparisonDetail>(`/api/backoffice/comparisons/${id}`)
  },

  createComparison(request: CreateComparisonRequest) {
    return apiClient.post<{ id: string }>('/api/backoffice/comparisons', request)
  },

  updateComparison(id: string, request: UpdateComparisonRequest) {
    return apiClient.put(`/api/backoffice/comparisons/${id}`, request)
  },

  updateComparisonStatus(id: string, isActive: boolean) {
    return apiClient.patch(`/api/backoffice/comparisons/${id}/status`, { isActive })
  },

  getComparisonResults(id: string) {
    return apiClient.get<ComparisonResult>(`/api/backoffice/comparisons/${id}/results`)
  },

  getUsersSummary() {
    return apiClient.get<BackofficeUsersSummary>('/api/backoffice/users/summary')
  },
}
