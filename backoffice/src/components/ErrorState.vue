<template>
  <div class="rounded-xl border border-red-200 bg-red-50 px-4 py-6 text-center text-red-700">
    <p class="font-medium">{{ title }}</p>
    <p v-if="message" class="mt-1 text-sm">{{ message }}</p>
    <button
      v-if="retry"
      type="button"
      class="mt-4 rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700"
      @click="retry"
    >
      Tekrar dene
    </button>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  title?: string
  message?: string
  retry?: () => void
}>()
</script>
