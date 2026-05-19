<template>
  <div>
    <AppTopbar title="Yeni karşılaştırma" subtitle="İki seçenekli yeni içerik oluşturun" />

    <p v-if="success" class="mt-4 rounded-lg bg-emerald-50 px-4 py-3 text-sm text-emerald-800">
      Karşılaştırma başarıyla oluşturuldu.
    </p>

    <ComparisonForm
      v-model="form"
      class="mt-6"
      :categories="categories"
      :submitting="submitting"
      :server-error="serverError"
      submit-label="Oluştur"
      @submit="onSubmit"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import AppTopbar from '@/components/AppTopbar.vue'
import ComparisonForm, { type ComparisonFormModel } from '@/components/ComparisonForm.vue'
import { backofficeApi } from '@/services/backofficeApi'
import { getErrorMessage } from '@/services/apiClient'

const router = useRouter()
const categories = ref<string[]>([])
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

onMounted(async () => {
  try {
    const { data } = await backofficeApi.getCategories()
    categories.value = data
  } catch {
    categories.value = []
  }
})

async function onSubmit() {
  submitting.value = true
  serverError.value = null
  success.value = false
  try {
    const { data } = await backofficeApi.createComparison({
      titleTr: form.value.titleTr,
      titleEn: form.value.titleEn,
      category: form.value.category,
      isActive: form.value.isActive,
      leftOption: form.value.leftOption,
      rightOption: form.value.rightOption,
    })
    success.value = true
    await router.push(`/comparisons/${data.id}/edit`)
  } catch (e) {
    serverError.value = getErrorMessage(e)
  } finally {
    submitting.value = false
  }
}
</script>
