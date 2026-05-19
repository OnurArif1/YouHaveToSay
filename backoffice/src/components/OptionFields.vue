<template>
  <div class="space-y-3">
    <div>
      <label class="mb-1 block text-sm font-medium">Metin (TR) *</label>
      <input v-model="model.textTr" class="input" required />
    </div>
    <div>
      <label class="mb-1 block text-sm font-medium">Metin (EN)</label>
      <input v-model="model.textEn" class="input" />
    </div>
    <div>
      <label class="mb-1 block text-sm font-medium">Görsel URL</label>
      <input v-model="model.imageUrl" class="input" type="url" placeholder="https://..." />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { ComparisonOptionInput } from '@/types/backoffice'

const props = defineProps<{ modelValue: ComparisonOptionInput }>()
const emit = defineEmits<{ 'update:modelValue': [ComparisonOptionInput] }>()

const model = computed({
  get: () => props.modelValue,
  set: (v) => emit('update:modelValue', v),
})
</script>

<style scoped>
@reference "tailwindcss";

.input {
  @apply w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500;
}
</style>
