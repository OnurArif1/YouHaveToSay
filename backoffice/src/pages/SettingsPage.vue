<template>
  <div>
    <AppTopbar title="Ayarlar" subtitle="Backoffice yapılandırması" />
    <div class="mt-6 max-w-lg rounded-xl border border-slate-200 bg-white p-6 text-sm text-slate-600 shadow-sm">
      <p><strong>API:</strong> {{ apiBaseUrl }}</p>
      <p class="mt-2">
        Admin erişimi sunucu tarafında <code>Backoffice:AdminEmails</code> ile kontrol edilir.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import AppTopbar from '@/components/AppTopbar.vue'

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5106'
</script>
