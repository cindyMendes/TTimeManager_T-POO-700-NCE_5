<template>
  <div class="bg-bat-gray rounded-lg shadow-bat p-6" role="region" aria-labelledby="time-tracker-title">
    <h2 id="time-tracker-title" class="text-2xl font-bold mb-6 text-bat-yellow">Gotham Time Tracker</h2>
    
    <div class="mb-6" aria-live="polite">
      <p v-if="isClockedIn" class="text-bat-blue font-semibold">
        Vigilance active depuis : <span class="text-bat-yellow">{{ startTime }}</span>
      </p>
      <p v-else-if="endTime" class="text-bat-silver">
        Patrouille terminée à : <span class="text-bat-yellow">{{ endTime }}</span>
      </p>
    </div>

    <button
      @click="toggleClock"
      :disabled="loading"
      :aria-busy="loading"
      :class="[
        'bat-button w-full mb-4',
        isClockedIn ? 'bat-button-blue' : 'bat-button-yellow',
        loading ? 'opacity-50 cursor-not-allowed' : ''
      ]"
    >
      {{ isClockedIn ? 'Terminer la patrouille' : 'Débuter la patrouille' }}
    </button>

    <button
      @click="refresh"
      :disabled="loading"
      :aria-busy="loading"
      :class="['bat-button bat-button-gray w-full', loading ? 'opacity-50 cursor-not-allowed' : '']"
    >
      Actualiser le statut
    </button>

    <div v-if="loading" class="mt-4 text-center" aria-live="polite">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-bat-yellow" role="status">
        <span class="sr-only">Chargement en cours...</span>
      </div>
    </div>

    <div v-if="error" class="mt-4 text-red-500" role="alert">
      {{ error }}
    </div>

    <div v-if="apiResponse" class="mt-4">
      <h3 id="api-response-title" class="text-xl font-bold mb-2 text-bat-yellow">Détails de la réponse API :</h3>
      <div class="overflow-x-auto">
        <table aria-labelledby="api-response-title" class="min-w-full bg-bat-black border border-bat-gray rounded-lg overflow-hidden">
          <caption class="sr-only">Détails de la dernière patrouille</caption>
          <thead>
            <tr class="bg-bat-yellow text-bat-black">
              <th scope="col" class="py-2 px-4 border-b border-bat-gray">Statut</th>
              <th scope="col" class="py-2 px-4 border-b border-bat-gray">Heure de début</th>
              <th scope="col" class="py-2 px-4 border-b border-bat-gray">Heure de fin</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td class="py-2 px-4 border-b border-bat-gray">
                {{ isClockedIn ? 'En cours' : (endTime ? 'Terminée' : 'Non commencée') }}
              </td>
              <td class="py-2 px-4 border-b border-bat-gray">
                {{ startTime || 'Non définie' }}
              </td>
              <td class="py-2 px-4 border-b border-bat-gray">
                {{ endTime || 'Non définie' }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import api from '@/services/api_token';

export default {
  setup() {
    const route = useRoute();
    const isClockedIn = ref(false); 
    const startTime = ref(null); 
    const endTime = ref(null); 
    const loading = ref(false);
    const userId = ref(null);
    const error = ref(null);
    const apiResponse = ref(null); 
    const patrolId = ref(null); 

    const getAuthToken = () => {
      return localStorage.getItem('token'); 
    };

    const setAuthHeader = () => {
      const token = getAuthToken();
      if (!token) {
        throw new Error('Token JWT non trouvé. L\'utilisateur doit se reconnecter.');
      }
      return {
        headers: {
          Authorization: `Bearer ${token}` 
        }
      };
    };

    const refresh = async () => {
      if (!userId.value) {
        error.value = "Aucun utilisateur sélectionné";
        return;
      }

      isClockedIn.value = false;
      startTime.value = null;
      endTime.value = null;

      loading.value = true;
      error.value = null;

      try {
        const response = await api.get(`/clocks/${userId.value}`, setAuthHeader());
        apiResponse.value = response.data; 
        if (response.data && response.data.length > 0) {
          const lastClock = response.data[response.data.length - 1];
          isClockedIn.value = lastClock.status === 'true'; 
          startTime.value = isClockedIn.value ? new Date(lastClock.time).toLocaleString() : startTime.value; 
          endTime.value = !isClockedIn.value ? new Date(lastClock.time).toLocaleString() : endTime.value; 
        }
      } catch (err) {
        console.error('Erreur lors du rafraîchissement:', err);
        error.value = "Erreur lors de la récupération des données";
      } finally {
        loading.value = false;
      }
    };

    const toggleClock = async () => {
      if (!userId.value) {
        error.value = "Aucun utilisateur sélectionné";
        return;
      }
      loading.value = true;
      error.value = null;
      try {
        const newStatus = !isClockedIn.value;
        const response = await api.post(`/clocks/${userId.value}`, {
          time: new Date().toISOString(),
          status: newStatus
        }, setAuthHeader());
        
        apiResponse.value = response.data; 
        patrolId.value = response.data.data?.id; 

        isClockedIn.value = newStatus;

        if (newStatus) {
          startTime.value = new Date().toLocaleString(); 
          endTime.value = null; 
        } else {
          endTime.value = new Date().toLocaleString();
        }
      } catch (err) {
        console.error('Erreur lors du changement d\'état:', err);
        error.value = "Erreur lors du changement d'état";
      } finally {
        loading.value = false;
      }
    };

    onMounted(() => {
      userId.value = route.query.id;
      if (userId.value) {
        refresh();
      } else {
        error.value = "Aucun utilisateur sélectionné";
      }
    });

    watch(() => route.query.id, (newId) => {
      userId.value = newId;
      if (userId.value) {
        refresh();
      } else {
        error.value = "Aucun utilisateur sélectionné";
      }
    });

    return {
      isClockedIn,
      startTime,
      endTime,
      loading,
      userId,
      error,
      apiResponse, 
      patrolId, 
      refresh,
      toggleClock
    };
  }
};
</script>
