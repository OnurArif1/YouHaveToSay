<template>
  <div class="flex min-h-screen">
    <AppSidebar />
    <div class="flex min-w-0 flex-1 flex-col">
      <main class="flex-1 overflow-auto p-6">
        <RouterView />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import AppSidebar from '@/components/AppSidebar.vue'
</script>
