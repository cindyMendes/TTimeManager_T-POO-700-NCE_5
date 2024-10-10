<template>
  <div id="app" class="min-h-screen bg-gray-100">
    <nav class="bg-blue-600 p-4 text-white">
      <h1 class="text-2xl font-bold">Time Manager</h1>
    </nav>
    
    <div class="container mx-auto p-4">
      <User />
      
      <div class="mt-8 grid grid-cols-1 md:grid-cols-2 gap-6">
        <router-view></router-view>
      </div>
    </div>
  </div>
</template>

<script>
import User from './components/User.vue'

export default {
  name: 'App',
  components: {
    User
  }
}
</script>

<style>
/* Vous pouvez ajouter des styles globaux ici si nécessaire */
</style>