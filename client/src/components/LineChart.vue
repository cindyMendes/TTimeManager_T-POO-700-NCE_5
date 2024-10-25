<template>
  <div class="bg-bat-gray rounded-lg shadow-bat p-6">
    <h2 class="text-1xl font-bold mb-6 text-bat-yellow">Daily Hours Line Chart</h2>

    <!-- Date picker -->
    <div class="date-picker">
      <label for="start-date" class="block text-sm font-medium text-bat-silver mb-1">
        Select Start Date:
      </label>
      <input 
        type="date" 
        id="start-date" 
        v-model="selectedStartDate" 
        @change="fetchChartData"
        :disabled="loading"
        class="px-3 py-2 bg-bat-gray border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow" 
      />
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="flex justify-center items-center py-8">
      <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-bat-yellow"></div>
      <span class="ml-2 text-bat-silver">Loading chart data...</span>
    </div>

    <!-- Error message -->
    <div v-else-if="error" class="bg-red-900 text-bat-silver p-4 rounded-md my-4">
      {{ error }}
    </div>

    <!-- Chart -->
    <div v-else class="chart-container">
      <LineChart 
        v-if="chartData" 
        :chart-data="chartData" 
        :options="chartOptions" 
      />
      <p v-else class="text-bat-silver text-center py-4">
        No data available for the selected period
      </p>
    </div>
    
    <!-- Total hours -->
    <div v-if="totalHours !== null" class="total-hours mt-4 text-bat-silver">
      <p>Total hours worked: <strong class="text-bat-yellow">{{ totalHours.toFixed(1) }}</strong></p>
    </div>
  </div>
</template>

<script>
import { defineComponent, ref, onMounted, watch } from "vue";
import { LineChart } from "vue-chart-3";
import "chart.js/auto";
import api from '@/services/api_token';

export default defineComponent({
  name: 'HoursLineChart',
  components: {
    LineChart,
  },
  props: {
    userId: {
      type: [String, Number],
      required: true,
    },
  },
  setup(props) {
    const chartData = ref(null);
    const loading = ref(false);
    const error = ref(null);
    const totalHours = ref(null);
    const selectedStartDate = ref(null);

    const chartOptions = ref({
      responsive: true,
      scales: {
        y: {
          beginAtZero: true,
          title: {
            display: true,
            text: "Hours Worked",
            color: '#C0C0C0'
          },
          ticks: {
            color: '#C0C0C0'
          }
        },
        x: {
          title: {
            display: true,
            text: "Days of the Week",
            color: '#C0C0C0'
          },
          ticks: {
            color: '#C0C0C0'
          }
        }
      },
      plugins: {
        legend: {
          labels: {
            color: '#C0C0C0'
          }
        }
      }
    });

    const fetchChartData = async () => {
      if (!selectedStartDate.value || !props.userId) {
        error.value = "Please select a start date and ensure user is selected.";
        return;
      }

      loading.value = true;
      error.value = null;

      try {
        const startDate = selectedStartDate.value;
        const currentWeekDates = getCurrentWeekDates(startDate);
        const endDate = currentWeekDates[6];

        const response = await api.get("/reports/weekly_hours", {
          params: { 
            user_id: props.userId, 
            start_date: startDate, 
            end_date: endDate 
          }
        });

        if (!response.data || !response.data.hours_by_day) {
          throw new Error('Invalid data format received from server');
        }

        const hoursByDay = response.data.hours_by_day;
        const labels = currentWeekDates.map(date => formatDateToLabel(date));
        const hoursWorked = labels.map((_, index) => {
          const date = currentWeekDates[index];
          return hoursByDay[date] || 0;
        });

        totalHours.value = hoursWorked.reduce((total, hours) => total + hours, 0);

        chartData.value = {
          labels,
          datasets: [{
            label: "Hours Worked",
            backgroundColor: "#42A5F5",
            borderColor: "#42A5F5",
            fill: false,  // Important for LineChart
            data: hoursWorked,
          }]
        };
      } catch (err) {
        handleError(err);
      } finally {
        loading.value = false;
      }
    };

    const getCurrentWeekDates = (startDate) => {
      const start = new Date(startDate);
      const dates = [];
      for (let i = 0; i < 7; i++) {
        const date = new Date(start);
        date.setDate(start.getDate() + i);
        dates.push(date.toISOString().split('T')[0]);
      }
      return dates;
    };

    const formatDateToLabel = (dateString) => {
      const date = new Date(dateString);
      return new Intl.DateTimeFormat('fr-FR', { 
        weekday: 'short',
        month: 'short', 
        day: 'numeric'
      }).format(date);
    };

    const handleError = (error) => {
      console.error('Error:', error);
      error.value = error.response?.status === 401
        ? "Session expirée. Veuillez vous reconnecter."
        : error.response?.status === 403
        ? "Accès non autorisé."
        : "Erreur lors de la récupération des données.";
    };

    onMounted(() => {
      const today = new Date();
      today.setDate(today.getDate() - today.getDay() + 1); // Set to Monday of current week
      selectedStartDate.value = today.toISOString().split('T')[0];
      
      if (props.userId) {
        fetchChartData();
      }
    });

    watch(() => props.userId, (newUserId) => {
      if (newUserId) fetchChartData();
    });

    return {
      chartData,
      chartOptions,
      selectedStartDate,
      fetchChartData,
      loading,
      error,
      totalHours
    };
  }
});
</script>

<style scoped>
.date-picker {
  margin-bottom: 20px;
}

.chart-container {
  width: 100%;
  height: 400px;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 8px;
  padding: 16px;
}

.total-hours {
  margin-top: 20px;
  font-size: 16px;
  padding: 12px;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 8px;
}
</style>
