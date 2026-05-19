<template>
  <div>
    <AppTopbar title="Dashboard" subtitle="Karşılaştırma ve oy özeti" />

    <LoadingState v-if="loading" />
    <ErrorState v-else-if="error" :message="error" :retry="load" />
    <template v-else-if="dashboard">
      <div class="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        <StatCard label="Toplam karşılaştırma" :value="dashboard.totalComparisons" />
        <StatCard label="Aktif" :value="dashboard.activeComparisons" helper="Yayında" />
        <StatCard label="Pasif" :value="dashboard.inactiveComparisons" />
        <StatCard label="Toplam oy" :value="dashboard.totalVotes" />
        <StatCard label="Bu hafta oluşturulan" :value="dashboard.comparisonsCreatedThisWeek" />
        <StatCard
          label="Ortalama oy / karşılaştırma"
          :value="dashboard.averageVotesPerComparison"
        />
      </div>

      <section class="mt-8">
        <h2 class="mb-3 text-lg font-semibold">En çok oy alanlar</h2>
        <ComparisonTable :items="dashboard.mostVotedComparisons" show-results />
      </section>

      <section class="mt-8">
        <h2 class="mb-3 text-lg font-semibold">Son eklenenler</h2>
        <ComparisonTable :items="dashboard.latestComparisons" show-edit />
      </section>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import AppTopbar from '@/components/AppTopbar.vue'
import StatCard from '@/components/StatCard.vue'
import LoadingState from '@/components/LoadingState.vue'
import ErrorState from '@/components/ErrorState.vue'
import ComparisonTable from '@/components/ComparisonTable.vue'
import { backofficeApi } from '@/services/backofficeApi'
import { getErrorMessage } from '@/services/apiClient'
import type { BackofficeDashboard } from '@/types/backoffice'

const dashboard = ref<BackofficeDashboard | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)

async function load() {
  loading.value = true
  error.value = null
  try {
    const { data } = await backofficeApi.getDashboard()
    dashboard.value = data
  } catch (e) {
    error.value = getErrorMessage(e)
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>
