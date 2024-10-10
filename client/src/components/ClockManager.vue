<template>
  <div class="bg-white p-6 rounded-lg shadow-md">
    <h2 class="text-2xl font-semibold mb-4">Gestion du temps</h2>
    <p>Statut : {{ clockIn ? 'En cours de travail' : 'Pas en cours de travail' }}</p>
    <p v-if="startDateTime">Début : {{ startDateTime }}</p>
    <button @click="clock" class="bg-blue-500 text-white px-4 py-2 rounded mt-4">
      {{ clockIn ? 'Arrêter le travail' : 'Commencer le travail' }}
    </button>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'

export default {
  name: 'ClockManager',
  setup() {
    const clockIn = ref(false)
    const startDateTime = ref(null)

    const refresh = async () => {
      // Implementez la récupération du statut actuel depuis l'API
    }

    const clock = async () => {
      // Implementez le changement de statut (début/fin de travail)
      clockIn.value = !clockIn.value
      if (clockIn.value) {
        startDateTime.value = new Date().toISOString().slice(0, 19).replace('T', ' ')
      } else {
        startDateTime.value = null
      }
    }

    onMounted(refresh)

    return {
      clockIn,
      startDateTime,
      clock
    }
  }
}
</script>