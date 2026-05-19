<template>
  <div>
    <AppTopbar title="Karşılaştırmalar" subtitle="Tüm karşılaştırmaları yönetin">
      <RouterLink
        to="/comparisons/create"
        class="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700"
      >
        Yeni oluştur
      </RouterLink>
    </AppTopbar>

    <div class="mt-6 flex flex-wrap gap-3 rounded-xl border border-slate-200 bg-white p-4">
      <input v-model="filters.search" placeholder="Ara..." class="filter-input" @keyup.enter="load" />
      <select v-model="filters.category" class="filter-input">
        <option value="">Tüm kategoriler</option>
        <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
      </select>
      <select v-model="statusFilter" class="filter-input">
        <option value="">Tüm durumlar</option>
        <option value="true">Aktif</option>
        <option value="false">Pasif</option>
      </select>
      <select v-model="filters.sortBy" class="filter-input">
        <option value="createdAt">Oluşturma tarihi</option>
        <option value="totalVotes">Oy sayısı</option>
      </select>
      <select v-model="filters.sortDirection" class="filter-input">
        <option value="desc">Azalan</option>
        <option value="asc">Artan</option>
      </select>
      <button type="button" class="rounded-lg bg-slate-800 px-4 py-2 text-sm text-white" @click="load">
        Filtrele
      </button>
    </div>

    <LoadingState v-if="loading" class="mt-6" />
    <ErrorState v-else-if="error" class="mt-6" :message="error" :retry="load" />
    <template v-else>
      <div class="mt-6 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
        <table v-if="items.length" class="min-w-full text-sm">
          <thead class="bg-slate-50 text-left text-slate-500">
            <tr>
              <th class="px-4 py-3">Başlık</th>
              <th class="px-4 py-3">Sol</th>
              <th class="px-4 py-3">Sağ</th>
              <th class="px-4 py-3">Kategori</th>
              <th class="px-4 py-3">Durum</th>
              <th class="px-4 py-3">Oy</th>
              <th class="px-4 py-3">Oluşturulma</th>
              <th class="px-4 py-3">İşlemler</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="item in items" :key="item.id">
              <td class="max-w-[12rem] truncate px-4 py-3 font-medium">{{ item.titleTr }}</td>
              <td class="px-4 py-3">{{ item.leftOptionText }}</td>
              <td class="px-4 py-3">{{ item.rightOptionText }}</td>
              <td class="px-4 py-3">{{ item.category }}</td>
              <td class="px-4 py-3"><StatusBadge :active="item.isActive" /></td>
              <td class="px-4 py-3">{{ item.totalVotes }}</td>
              <td class="px-4 py-3 text-slate-500">{{ formatDate(item.createdAt) }}</td>
              <td class="px-4 py-3">
                <div class="flex flex-wrap gap-2">
                  <RouterLink :to="`/comparisons/${item.id}/results`" class="action-link">Sonuçlar</RouterLink>
                  <RouterLink :to="`/comparisons/${item.id}/edit`" class="action-link">Düzenle</RouterLink>
                  <button type="button" class="action-link" @click="toggleStatus(item)">
                    {{ item.isActive ? 'Pasifleştir' : 'Aktifleştir' }}
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <EmptyState v-else class="m-4" title="Karşılaştırma bulunamadı" />
      </div>

      <div v-if="totalPages > 1" class="mt-4 flex items-center justify-between text-sm">
        <p class="text-slate-500">Toplam {{ totalCount }} kayıt</p>
        <div class="flex gap-2">
          <button
            type="button"
            class="rounded border px-3 py-1 disabled:opacity-40"
            :disabled="page <= 1"
            @click="page--; load()"
          >
            Önceki
          </button>
          <span class="px-2 py-1">{{ page }} / {{ totalPages }}</span>
          <button
            type="button"
            class="rounded border px-3 py-1 disabled:opacity-40"
            :disabled="page >= totalPages"
            @click="page++; load()"
          >
            Sonraki
          </button>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import AppTopbar from '@/components/AppTopbar.vue'
import LoadingState from '@/components/LoadingState.vue'
import ErrorState from '@/components/ErrorState.vue'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { backofficeApi } from '@/services/backofficeApi'
import { getErrorMessage } from '@/services/apiClient'
import type { BackofficeComparisonListItem } from '@/types/backoffice'

const items = ref<BackofficeComparisonListItem[]>([])
const categories = ref<string[]>([])
const loading = ref(true)
const error = ref<string | null>(null)
const page = ref(1)
const pageSize = 20
const totalCount = ref(0)
const totalPages = ref(0)
const statusFilter = ref('')

const filters = reactive({
  search: '',
  category: '',
  sortBy: 'createdAt',
  sortDirection: 'desc',
})

async function loadCategories() {
  try {
    const { data } = await backofficeApi.getCategories()
    categories.value = data
  } catch {
    categories.value = []
  }
}

async function load() {
  loading.value = true
  error.value = null
  try {
    const { data } = await backofficeApi.getComparisons({
      page: page.value,
      pageSize,
      search: filters.search || undefined,
      category: filters.category || undefined,
      isActive: statusFilter.value === '' ? undefined : statusFilter.value === 'true',
      sortBy: filters.sortBy,
      sortDirection: filters.sortDirection,
    })
    items.value = data.items
    totalCount.value = data.totalCount
    totalPages.value = data.totalPages
  } catch (e) {
    error.value = getErrorMessage(e)
  } finally {
    loading.value = false
  }
}

async function toggleStatus(item: BackofficeComparisonListItem) {
  await backofficeApi.updateComparisonStatus(item.id, !item.isActive)
  await load()
}

function formatDate(value: string) {
  return new Date(value).toLocaleString('tr-TR')
}

onMounted(async () => {
  await loadCategories()
  await load()
})
</script>

<style scoped>
@reference "tailwindcss";

.filter-input {
  @apply rounded-lg border border-slate-300 px-3 py-2 text-sm;
}

.action-link {
  @apply text-indigo-600 hover:underline;
}
</style>
