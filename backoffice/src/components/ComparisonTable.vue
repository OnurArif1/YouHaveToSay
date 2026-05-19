<template>
  <div class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
    <table v-if="items.length" class="min-w-full text-sm">
      <thead class="bg-slate-50 text-left text-slate-500">
        <tr>
          <th class="px-4 py-3 font-medium">Karşılaştırma</th>
          <th class="px-4 py-3 font-medium">Kategori</th>
          <th class="px-4 py-3 font-medium">Oy</th>
          <th class="px-4 py-3 font-medium">Durum</th>
          <th class="px-4 py-3 font-medium">İşlem</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-slate-100">
        <tr v-for="item in items" :key="item.id" class="hover:bg-slate-50">
          <td class="max-w-xs truncate px-4 py-3 font-medium">{{ item.titleTr }}</td>
          <td class="px-4 py-3">{{ item.category }}</td>
          <td class="px-4 py-3">{{ item.totalVotes }}</td>
          <td class="px-4 py-3">
            <StatusBadge :active="item.isActive" />
          </td>
          <td class="px-4 py-3">
            <RouterLink
              v-if="showResults"
              :to="`/comparisons/${item.id}/results`"
              class="text-indigo-600 hover:underline"
            >
              Sonuçlar
            </RouterLink>
            <RouterLink
              v-if="showEdit"
              :to="`/comparisons/${item.id}/edit`"
              class="text-indigo-600 hover:underline"
            >
              Düzenle
            </RouterLink>
          </td>
        </tr>
      </tbody>
    </table>
    <EmptyState v-else title="Kayıt yok" description="Henüz karşılaştırma bulunmuyor." />
  </div>
</template>

<script setup lang="ts">
import StatusBadge from './StatusBadge.vue'
import EmptyState from './EmptyState.vue'
import type { BackofficeComparisonListItem } from '@/types/backoffice'

defineProps<{
  items: BackofficeComparisonListItem[]
  showResults?: boolean
  showEdit?: boolean
}>()
</script>
