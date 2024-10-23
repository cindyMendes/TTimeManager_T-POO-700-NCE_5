<template>
  <div class="bg-bat-gray rounded-lg shadow-bat p-6 flex flex-col items-center justify-center min-h-screen">
    <h2 class="text-2xl font-bold mb-6 text-bat-yellow text-center">
      Analytique du Vigilant de Gotham - Utilisateur {{ displayUserId }}
    </h2>

    <div v-if="loading" class="text-center py-4">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-bat-yellow"></div>
      <p class="mt-2 text-bat-silver">Accès au Bat-Ordinateur en cours...</p>
    </div>

    <div v-else-if="errorMessage" class="bg-red-900 border-l-4 border-bat-yellow text-bat-silver p-4 mb-4" role="alert">
      <p class="font-bold">Alerte</p>
      <p>{{ errorMessage }}</p>
    </div>

    <div v-else-if="!chartData.datasets.length" class="text-center py-4 text-bat-silver">
      Aucune donnée de patrouille disponible pour ce vigilant.
    </div>

    <div v-else class="flex justify-center items-center w-full">
      <div class="bg-bat-black p-4 rounded-lg shadow-inner" style="height: 400px; width: 400px;">
        <h3 class="text-xl font-bold mb-4 text-bat-yellow text-center">Répartition du Temps de Patrouille</h3>
        <Pie :data="chartData" :options="chartOptions" />
      </div>
    </div>

    <button 
      @click="fetchData" 
      class="mt-8 bg-bat-blue text-white py-2 px-4 rounded hover:bg-bat-blue-dark mx-auto">
      Actualiser les Données
    </button>
  </div>
</template>


<script>
import { ref, onMounted, computed, watch } from 'vue';
import { useRoute } from 'vue-router';
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'
import { Pie } from 'vue-chartjs'
import api from '@/services/api_token';

ChartJS.register(ArcElement, Tooltip, Legend)

export default {
  name: 'ChartManager',
  components: { Pie },
  setup() {
    const route = useRoute();
    const loading = ref(true);
    const errorMessage = ref(null);
    const workingTimes = ref([]);
    const timeDistributionData = ref(null);
    const userId = ref(null);
    const displayUserId = computed(() => userId.value || 'Non sélectionné');


    const batColors = {
      yellow: '#FFFF00',
      silver: '#C0C0C0',
      black: '#0A0A0A',
    };

    const chartOptions = {
      responsive: true,
      maintainAspectRatio: true,
      plugins: {
        legend: {
          labels: {
            color: batColors.silver,
          },
        },
        tooltip: {
          callbacks: {
            label: (context) => {
              const label = context.label || '';
              const value = context.raw || 0;
              const total = context.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
              const percentage = ((value / total) * 100).toFixed(1);
              return `${label}: ${percentage}% (${formatDuration(value)})`;
            },
          },
        },
      },
    };

    const formatDuration = (minutes) => {
      const hours = Math.floor(minutes / 60);
      const mins = minutes % 60;
      return `${hours}h ${mins}m`;
    };


    const fetchData = async () => {
  console.log("Fetching data for user ID:", userId.value);
  if (!userId.value) {
    errorMessage.value = "Aucun utilisateur sélectionné";
    return;
  }
  loading.value = true;
  errorMessage.value = null;
  try {
    const response = await api.get(`/workingtimes/${userId.value}/times`);
    // console.log("API response:", response.data);

    const data = response.data.data;
    if (Array.isArray(data)) {
      workingTimes.value = data;  
    } else if (typeof data === 'object' && data !== null) {
      workingTimes.value = [data]; 
    } else {
      throw new Error("Les données retournées ne sont ni un tableau ni un objet valide.");
    }
    
    processChartData(); 
  } catch (error) {
    console.error("Error details:", error.response || error);
    if (error.response?.status === 401) {
      errorMessage.value = "Session expirée. Veuillez vous reconnecter.";
    } else if (error.response?.status === 403) {
      errorMessage.value = "Accès non autorisé.";
    } else {
      errorMessage.value = "Erreur d'accès au Bat-Ordinateur. Veuillez réessayer.";
    }
  } finally {
    loading.value = false;
  }
};

const processChartData = () => {
  if (!Array.isArray(workingTimes.value) || workingTimes.value.length === 0) {
    console.log("No working times data available");
    return;
  }

  const timeData = workingTimes.value.map(time => {
    const start = new Date(time.start);
    const end = new Date(time.end);
    return (end - start) / (1000 * 60); 
  });

  timeDistributionData.value = {
    labels: workingTimes.value.map((_, index) => `Patrol ${index + 1}`),
    datasets: [{
      data: timeData,
      backgroundColor: Object.values(batColors),
    }],
  };
};



    onMounted(() => {
      userId.value = route.query.id;
      console.log("Component mounted. User ID:", userId.value);
      if (userId.value) {
        fetchData();
      } else {
        errorMessage.value = "Aucun utilisateur sélectionné";
      }
    });

    watch(() => route.query.id, (newId) => {
      userId.value = newId;
      console.log("User ID changed to:", userId.value);
      if (userId.value) {
        fetchData();
      } else {
        errorMessage.value = "Aucun utilisateur sélectionné";
      }
    });

    

    const chartData = computed(() => ({
      labels: timeDistributionData.value ? timeDistributionData.value.labels : [],
      datasets: timeDistributionData.value ? timeDistributionData.value.datasets : []
    }));

    return {
      loading,
      errorMessage,
      chartData,
      chartOptions,
      fetchData,
      displayUserId,
    };
  },
};
</script>