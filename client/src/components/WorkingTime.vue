<template>
  <div class="bg-bat-gray rounded-lg shadow-bat p-6">
    <h2 class="text-2xl font-bold mb-6 text-bat-yellow">Journal de Patrouille de Gotham</h2>

    <div v-if="loading" class="text-center py-4">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-bat-yellow"></div>
      <p class="mt-2 text-bat-silver">Accès au Bat-Ordinateur en cours...</p>
    </div>

    <div v-else-if="error" class="bg-red-900 border-l-4 border-bat-yellow text-bat-silver p-4 mb-4" role="alert">
      <p class="font-bold">Alerte</p>
      <p>{{ error }}</p>
    </div>

    <div v-else-if="workingTime" class="bg-bat-black p-6 rounded-lg shadow-inner">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <p class="text-bat-yellow font-semibold">ID de Mission :</p>
          <p class="text-bat-silver text-xl">{{ workingTime.id }}</p>
        </div>
        <div>
          <p class="text-bat-yellow font-semibold">ID du Vigilant :</p>
          <p class="text-bat-silver text-xl">{{ userId }}</p>
        </div>
        <div>
          <p class="text-bat-yellow font-semibold">Début de Patrouille :</p>
          <p class="text-bat-blue text-xl">{{ formatTime(workingTime.start) }}</p>
        </div>
        <div>
          <p class="text-bat-yellow font-semibold">Fin de Patrouille :</p>
          <p class="text-bat-blue text-xl">{{ formatTime(workingTime.end) }}</p>
        </div>
      </div>

      <div class="flex flex-wrap justify-between gap-2 mt-2">
        <button 
          @click="toggleEditMode"
          class="flex-grow bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600"
          :disabled="loading"
        >
          Modifier le Journal de Patrouille
        </button>
        <button 
          @click="confirmDelete"
          class="flex-grow bg-red-500 text-white py-2 px-4 rounded hover:bg-red-600"
          :disabled="loading"
        >
          Supprimer le Journal
        </button>
      </div>
    </div>

    <div v-else class="text-center py-4 text-bat-silver">
      Aucun journal de patrouille trouvé. La nuit est calme.
    </div>

    <!-- Formulaire de modification -->
    <div v-if="editMode" class="mt-8 bg-bat-black p-6 rounded-lg shadow-bat">
      <h3 class="text-lg font-semibold mb-4 text-bat-yellow">Modifier le Journal de Patrouille</h3>
      <form @submit.prevent="handleUpdate" class="space-y-4">
        <div>
          <label for="editStartTime" class="block text-sm font-medium text-bat-silver mb-1">Début de Patrouille :</label>
          <input 
            type="datetime-local" 
            id="editStartTime" 
            v-model="editForm.start" 
            required
            :disabled="loading"
            class="w-full px-3 py-2 bg-bat-gray border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow"
          >
        </div>
        <div>
          <label for="editEndTime" class="block text-sm font-medium text-bat-silver mb-1">Fin de Patrouille :</label>
          <input 
            type="datetime-local" 
            id="editEndTime" 
            v-model="editForm.end" 
            required
            :disabled="loading"
            class="w-full px-3 py-2 bg-bat-gray border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow"
          >
        </div>
        <div class="flex justify-end space-x-4">
          <button 
            type="button" 
            @click="cancelEdit" 
            class="px-4 py-2 bg-bat-gray text-bat-silver rounded-full shadow-bat hover:bg-opacity-90 transition duration-300 font-bold"
            :disabled="loading"
          >
            Annuler
          </button>
          <button 
            type="submit" 
            class="px-4 py-2 bg-bat-yellow text-bat-black rounded-full shadow-bat hover:bg-opacity-90 transition duration-300 font-bold"
            :disabled="loading"
          >
            Mettre à Jour le Journal
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import api from '@/services/api_token';
import { ref, onMounted } from 'vue';

export default {
  name: 'WorkingTime',
  props: {
    userId: {
      type: String,
      required: true
    },
    workingTimeId: {
      type: String,
      default: null
    }
  },

  setup(props) {
    const workingTime = ref(null);
    const loading = ref(false);
    const error = ref(null);
    const editMode = ref(false);
    const editForm = ref({
      start: '',
      end: ''
    });

    const fetchWorkingTime = async () => {
      if (!props.workingTimeId) return;
      
      loading.value = true;
      error.value = null;
      try {
        const response = await api.get(`/workingtime/${props.workingTimeId}`);
        workingTime.value = response.data.data;
        initializeEditForm();
      } catch (err) {
        handleError(err, "lors de la récupération du journal");
      } finally {
        loading.value = false;
      }
    };

    const createWorkingTime = async (data) => {
      loading.value = true;
      error.value = null;
      try {
        const response = await api.post(`/workingtime/${props.userId}`, data);
        workingTime.value = response.data.data;
        return response.data;
      } catch (err) {
        handleError(err, "lors de la création du journal");
        throw err;
      } finally {
        loading.value = false;
      }
    };

    const updateWorkingTime = async (data) => {
      if (!workingTime.value?.id) return;
      
      loading.value = true;
      error.value = null;
      try {
        const response = await api.put(`/workingtime/${workingTime.value.id}`, data);
        workingTime.value = response.data.data;
        editMode.value = false;
        return response.data;
      } catch (err) {
        handleError(err, "lors de la mise à jour du journal");
        throw err;
      } finally {
        loading.value = false;
      }
    };

    const deleteWorkingTime = async () => {
      if (!workingTime.value?.id) return;
      
      loading.value = true;
      error.value = null;
      try {
        await api.delete(`/workingtime/${workingTime.value.id}`);
        workingTime.value = null;
      } catch (err) {
        handleError(err, "lors de la suppression du journal");
      } finally {
        loading.value = false;
      }
    };

    const handleError = (error, context) => {
      console.error(`Erreur ${context}:`, error);
      if (error.response) {
        switch (error.response.status) {
          case 401:
            error.value = "Session expirée. Veuillez vous reconnecter.";
            setTimeout(() => {
              window.location.href = '/login';
            }, 2000);
            break;
          case 403:
            error.value = "Accès non autorisé.";
            break;
          case 404:
            error.value = "Journal de patrouille non trouvé.";
            break;
          case 422:
            error.value = "Données invalides. Veuillez vérifier les informations.";
            break;
          default:
            error.value = `Une erreur est survenue ${context}. Veuillez réessayer.`;
        }
      } else if (error.request) {
        error.value = "Impossible de contacter le serveur. Veuillez vérifier votre connexion.";
      } else {
        error.value = `Une erreur inattendue est survenue ${context}.`;
      }
    };

    const formatTime = (time) => {
      return new Date(time).toLocaleString('fr-FR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    };

    const toggleEditMode = () => {
      editMode.value = !editMode.value;
      if (editMode.value) {
        initializeEditForm();
      }
    };

    const initializeEditForm = () => {
      if (!workingTime.value) return;
      
      editForm.value = {
        start: workingTime.value.start.slice(0, 16), // Format for datetime-local input
        end: workingTime.value.end.slice(0, 16)
      };
    };

    const handleUpdate = async () => {
      if (new Date(editForm.value.end) <= new Date(editForm.value.start)) {
        error.value = "La fin de patrouille doit être après le début.";
        return;
      }

      await updateWorkingTime(editForm.value);
    };

    const confirmDelete = async () => {
      if (confirm("Êtes-vous sûr de vouloir supprimer ce journal de patrouille ?")) {
        await deleteWorkingTime();
      }
    };

    const cancelEdit = () => {
      editMode.value = false;
      error.value = null;
      initializeEditForm();
    };

    onMounted(() => {
      fetchWorkingTime();
    });

    return {
      workingTime,
      loading,
      error,
      editMode,
      editForm,
      formatTime,
      toggleEditMode,
      handleUpdate,
      confirmDelete,
      cancelEdit,
      createWorkingTime
    };
  }
};
</script>

<style scoped>
  /* Add any additional styles here */
</style>