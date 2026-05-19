<template>
  <div class="grid gap-6 lg:grid-cols-2">
    <form class="space-y-4 rounded-xl border border-slate-200 bg-white p-6 shadow-sm" @submit.prevent="onSubmit">
      <div>
        <label class="mb-1 block text-sm font-medium">Başlık (TR) *</label>
        <input v-model="model.titleTr" class="input" required />
      </div>
      <div>
        <label class="mb-1 block text-sm font-medium">Başlık (EN)</label>
        <input v-model="model.titleEn" class="input" />
      </div>
      <div>
        <label class="mb-1 block text-sm font-medium">Kategori *</label>
        <input v-model="model.category" class="input" list="categories" required />
        <datalist id="categories">
          <option v-for="cat in categories" :key="cat" :value="cat" />
        </datalist>
      </div>
      <label v-if="showActive" class="flex items-center gap-2 text-sm">
        <input v-model="model.isActive" type="checkbox" class="rounded" />
        Aktif
      </label>

      <hr class="border-slate-200" />

      <h3 class="font-medium text-slate-800">Sol seçenek</h3>
      <OptionFields v-model="model.leftOption" />

      <h3 class="font-medium text-slate-800">Sağ seçenek</h3>
      <OptionFields v-model="model.rightOption" />

      <p v-if="validationError" class="text-sm text-red-600">{{ validationError }}</p>
      <p v-if="serverError" class="text-sm text-red-600">{{ serverError }}</p>

      <div class="flex gap-3 pt-2">
        <button type="submit" class="btn-primary" :disabled="submitting || Boolean(validationError)">
          {{ submitting ? 'Kaydediliyor...' : submitLabel }}
        </button>
        <slot name="actions" />
      </div>
    </form>

    <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <p class="mb-4 text-sm font-medium text-slate-500">Önizleme</p>
      <div class="rounded-xl bg-slate-900 p-6 text-white">
        <p class="text-lg font-semibold">{{ model.titleTr || 'Başlık' }}</p>
        <p class="mt-1 text-xs text-slate-300">{{ model.category || 'kategori' }}</p>
        <div class="mt-6 grid grid-cols-2 gap-3">
          <div class="rounded-lg bg-slate-800 p-4 text-center">
            <p class="font-medium">{{ model.leftOption.textTr || 'Sol' }}</p>
          </div>
          <div class="rounded-lg bg-slate-800 p-4 text-center">
            <p class="font-medium">{{ model.rightOption.textTr || 'Sağ' }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import OptionFields from './OptionFields.vue'
import type { ComparisonOptionInput } from '@/types/backoffice'

export interface ComparisonFormModel {
  titleTr: string
  titleEn: string
  category: string
  isActive: boolean
  leftOption: ComparisonOptionInput
  rightOption: ComparisonOptionInput
}

const props = withDefaults(
  defineProps<{
    modelValue: ComparisonFormModel
    categories?: string[]
    showActive?: boolean
    submitting?: boolean
    submitLabel?: string
    serverError?: string | null
  }>(),
  {
    categories: () => [],
    showActive: true,
    submitting: false,
    submitLabel: 'Kaydet',
    serverError: null,
  },
)

const emit = defineEmits<{ submit: []; 'update:modelValue': [ComparisonFormModel] }>()

const model = computed({
  get: () => props.modelValue,
  set: (v) => emit('update:modelValue', v),
})

const validationError = computed(() => {
  const left = model.value.leftOption.textTr.trim()
  const right = model.value.rightOption.textTr.trim()
  if (left && right && left.toLowerCase() === right.toLowerCase()) {
    return 'Sol ve sağ seçenek metinleri aynı olamaz.'
  }
  return null
})

function onSubmit() {
  if (!validationError.value) {
    emit('submit')
  }
}
</script>

<style scoped>
@reference "tailwindcss";

.input {
  @apply w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500;
}

.btn-primary {
  @apply rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700 disabled:opacity-50;
}
</style>
