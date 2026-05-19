<template>
  <div>
    <AppTopbar title="Sonuçlar" :subtitle="result?.titleTr" />

    <LoadingState v-if="loading" class="mt-6" />
    <ErrorState v-else-if="error" class="mt-6" :message="error" :retry="load" />
    <template v-else-if="result && left && right">
      <div class="mt-6 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="flex flex-wrap items-center gap-3 text-sm text-slate-500">
          <span>Toplam oy: <strong class="text-slate-900">{{ result.totalVotes }}</strong></span>
          <span v-if="winnerLabel" class="rounded-full bg-indigo-100 px-3 py-1 text-indigo-800">
            {{ winnerLabel }}
          </span>
        </div>
      </div>

      <div class="mt-6 space-y-6">
        <ResultBar
          :label="left.textTr"
          :vote-count="left.voteCount"
          :percentage="left.percentage"
          :highlight="left.percentage > right.percentage"
        />
        <ResultBar
          :label="right.textTr"
          :vote-count="right.voteCount"
          :percentage="right.percentage"
          :highlight="right.percentage > left.percentage"
        />
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import AppTopbar from '@/components/AppTopbar.vue'
import LoadingState from '@/components/LoadingState.vue'
import ErrorState from '@/components/ErrorState.vue'
import ResultBar from '@/components/ResultBar.vue'
import { backofficeApi } from '@/services/backofficeApi'
import { getErrorMessage } from '@/services/apiClient'
import type { ComparisonResult } from '@/types/backoffice'

const props = defineProps<{ id: string }>()

const result = ref<ComparisonResult | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)

const left = computed(() => result.value?.options[0] ?? null)
const right = computed(() => result.value?.options[1] ?? null)

const winnerLabel = computed(() => {
  if (!result.value || result.value.totalVotes === 0) {
    return 'Henüz oy yok'
  }
  if (left.value && right.value && left.value.percentage === right.value.percentage) {
    return 'Berabere'
  }
  if (left.value && right.value && left.value.voteCount > right.value.voteCount) {
    return `Kazanan: ${left.value.textTr}`
  }
  if (right.value) {
    return `Kazanan: ${right.value.textTr}`
  }
  return null
})

async function load() {
  loading.value = true
  error.value = null
  try {
    const { data } = await backofficeApi.getComparisonResults(props.id)
    result.value = data
  } catch (e) {
    error.value = getErrorMessage(e)
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>
