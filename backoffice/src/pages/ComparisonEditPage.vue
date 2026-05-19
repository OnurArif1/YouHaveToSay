<template>
  <div>
    <AppTopbar title="Karşılaştırmayı düzenle" :subtitle="detail?.titleTr">
      <RouterLink
        v-if="id"
        :to="`/comparisons/${id}/results`"
        class="rounded-lg border border-slate-300 px-4 py-2 text-sm hover:bg-slate-50"
      >
        Sonuçları gör
      </RouterLink>
    </AppTopbar>

    <LoadingState v-if="loading" class="mt-6" />
    <ErrorState v-else-if="error" class="mt-6" :message="error" :retry="load" />
    <template v-else>
      <p v-if="success" class="mt-4 rounded-lg bg-emerald-50 px-4 py-3 text-sm text-emerald-800">
        Değişiklikler kaydedildi.
      </p>
      <ComparisonForm
        v-model="form"
        class="mt-6"
        :categories="categories"
        :show-active="false"
        :submitting="submitting"
        :server-error="serverError"
        @submit="onSubmit"
      />
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import AppTopbar from '@/components/AppTopbar.vue'
import ComparisonForm, { type ComparisonFormModel } from '@/components/ComparisonForm.vue'
import LoadingState from '@/components/LoadingState.vue'
import ErrorState from '@/components/ErrorState.vue'
import { backofficeApi } from '@/services/backofficeApi'
import { getErrorMessage } from '@/services/apiClient'
import type { BackofficeComparisonDetail } from '@/types/backoffice'

const props = defineProps<{ id: string }>()

const detail = ref<BackofficeComparisonDetail | null>(null)
const categories = ref<string[]>([])
const loading = ref(true)
const error = ref<string | null>(null)
const submitting = ref(false)
const serverError = ref<string | null>(null)
const success = ref(false)

const form = ref<ComparisonFormModel>({
  titleTr: '',
  titleEn: '',
  category: '',
  isActive: true,
  leftOption: { textTr: '', textEn: '', imageUrl: '' },
  rightOption: { textTr: '', textEn: '', imageUrl: '' },
})

function mapDetailToForm(d: BackofficeComparisonDetail) {
  const opts = [...d.options].sort((a, b) => a.displayOrder - b.displayOrder)
  form.value = {
    titleTr: d.titleTr,
    titleEn: d.titleEn,
    category: d.category,
    isActive: d.isActive,
    leftOption: {
      textTr: opts[0]?.textTr ?? '',
      textEn: opts[0]?.textEn ?? '',
      imageUrl: opts[0]?.imageUrl ?? '',
    },
    rightOption: {
      textTr: opts[1]?.textTr ?? '',
      textEn: opts[1]?.textEn ?? '',
      imageUrl: opts[1]?.imageUrl ?? '',
    },
  }
}

async function load() {
  loading.value = true
  error.value = null
  try {
    const [detailRes, categoriesRes] = await Promise.all([
      backofficeApi.getComparisonDetail(props.id),
      backofficeApi.getCategories(),
    ])
    detail.value = detailRes.data
    categories.value = categoriesRes.data
    mapDetailToForm(detailRes.data)
  } catch (e) {
    error.value = getErrorMessage(e)
  } finally {
    loading.value = false
  }
}

async function onSubmit() {
  submitting.value = true
  serverError.value = null
  success.value = false
  try {
    await backofficeApi.updateComparison(props.id, {
      titleTr: form.value.titleTr,
      titleEn: form.value.titleEn,
      category: form.value.category,
      leftOption: form.value.leftOption,
      rightOption: form.value.rightOption,
    })
    success.value = true
    await load()
  } catch (e) {
    serverError.value = getErrorMessage(e)
  } finally {
    submitting.value = false
  }
}

onMounted(load)
</script>
