Linechart


<template>
  <div class="bg-bat-gray rounded-lg shadow-bat p-6">
    <h2 class="text-1xl font-bold mb-6 text-bat-yellow">Daily Hours Chart</h2>

    <!-- Date picker to select the start of the week -->
    <div class="date-picker">
      <label for="start-date" class="block text-sm font-medium text-bat-silver mb-1">Select Start Date:</label>
      <input
        type="date"
        id="start-date"
        v-model="selectedStartDate"
        @change="fetchChartData"
        class="px-3 py-2 bg-bat-gray border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow"
      />
    </div>

    <!-- Chart container -->
    <div class="chart-container">
      <LineChart v-if="chartData" :chart-data="chartData" :options="chartOptions" />
      <p v-else class="text-bat-silver">{{ loadingMessage }}</p>
    </div>

    <!-- Total hours worked for the week -->
    <div v-if="totalHours !== null" class="total-hours text-bat-silver">
      <p>Total hours worked for the week: <strong>{{ totalHours }}</strong></p>
    </div>

    <!-- Error display -->
    <div v-if="error" class="mt-4 bg-red-900 text-bat-silver p-4 rounded-md">
      {{ error }}
    </div>
  </div>
</template>

<script>
import { defineComponent, ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { LineChart } from "vue-chart-3";
import "chart.js/auto";
import api from '@/services/api_token';

export default defineComponent({
  name: 'LineChartComponent',
  components: {
    LineChart,
  },
  setup() {
    const chartData = ref(null);
    const loadingMessage = ref("Loading chart...");
    const totalHours = ref(null); // For holding the total hours worked for the week
    const error = ref(null);
    
    const chartOptions = ref({
      responsive: true,
      scales: {
        y: {
          beginAtZero: true,
          title: {
            display: true,
            text: "Hours Worked",
            color: '#C0C0C0'  // bat-silver color
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

    const route = useRoute();
    const userId = ref(route.query.id);
    const selectedStartDate = ref(null);    // For the date picker
    const workingTimes = ref([]);           // To store the working times fetched from the new API
    const weeklyHours = ref([]);            // To store the weekly_hours data
    const totalWorkingHours = ref(0);       // Total hours from workingTimes
    const totalReportedHours = ref(0);      // Total hours from weekly_hours

    const fetchChartData = async () => {
      if (!selectedStartDate.value || !userId.value) {
        error.value = "Please select a start date and user.";
        return;
      }

      error.value = null;
      loadingMessage.value = "Loading chart...";
      chartData.value = null;

      const startDate = selectedStartDate.value;
      const currentWeekDates = getCurrentWeekDates(startDate);
      const endDate = currentWeekDates[6];

      try {
        await Promise.all([
          fetchWorkingTimesData(),
          fetchWeeklyHoursData(startDate, endDate)
        ]);
        processChartData(currentWeekDates);
      } catch (err) {
        handleError(err);
      }
    };

    const fetchWorkingTimesData = async () => {
      try {
        const response = await api.get(`/clocks/${userId.value}`);
        workingTimes.value = response.data.data;
      } catch (error) {
        throw new Error("Error fetching working times");
      }
    };

    const fetchWeeklyHoursData = async (startDate, endDate) => {
      try {
        const response = await api.get("/reports/weekly_hours", {
          params: { 
            user_id: userId.value, 
            start_date: startDate, 
            end_date: endDate 
          }
        });
        weeklyHours.value = response.data.hours_by_day;
      } catch (error) {
        throw new Error("Error fetching weekly hours");
      }
    };

    const processChartData = (currentWeekDates) => {
      const labels = currentWeekDates.map((date) => formatDateToLabel(date));
      const workingHoursByDay = {};

      let startTime = null;

      workingTimes.value.sort((a, b) => new Date(a.time) - new Date(b.time));

      workingTimes.value.forEach((entry) => {
        const dateKey = entry.time.split("T")[0];
        const entryTime = new Date(entry.time).getTime();

        if (entry.status === true) {
          startTime = entryTime;
        } else if (entry.status === false && startTime !== null && entryTime > startTime) {
          const duration = (entryTime - startTime) / (1000 * 60 * 60);
          workingHoursByDay[dateKey] = (workingHoursByDay[dateKey] || 0) + duration;
          startTime = null;
        }
      });

      const workingTimesData = labels.map((label) => {
        const date = label.split(", ")[1];
        return (workingHoursByDay[date] || 0);
      });

      const weeklyHoursData = labels.map((label, index) => {
        const date = currentWeekDates[index];
        return (weeklyHours.value[date] || 0);
      });

      totalWorkingHours.value = workingTimesData.reduce((total, hours) => total + hours, 0);
      totalReportedHours.value = weeklyHoursData.reduce((total, hours) => total + hours, 0);

      chartData.value = {
        labels,
        datasets: [
          {
            label: "Clock Times",
            backgroundColor: "rgba(66, 165, 245, 0.5)",
            borderColor: "#42A5F5",
            fill: false,
            data: workingTimesData,
          },
          {
            label: "Reported Weekly Hours",
            backgroundColor: "rgba(102, 187, 106, 0.5)",
            borderColor: "#66BB6A",
            fill: false,
            data: weeklyHoursData,
          },
        ],
      };

      totalHours.value = totalWorkingHours.value + totalReportedHours.value;
    };

    const getCurrentWeekDates = (startDate) => {
      const start = new Date(startDate);
      const dates = [];
      for (let i = 0; i < 7; i++) {
        const date = new Date(start);
        date.setDate(start.getDate() + i);
        dates.push(date.toISOString().split("T")[0]);
      }
      return dates;
    };

    const formatDateToLabel = (dateString) => {
      const date = new Date(dateString);
      const formatter = new Intl.DateTimeFormat("en-US", {
        month: "short",
        day: "numeric",
        year: "numeric"
      });
      return formatter.format(date);
    };

    const handleError = (error) => {
      console.error('Error:', error);
      if (error.response) {
        switch (error.response.status) {
          case 401:
            error.value = "Session expirée. Veuillez vous reconnecter.";
            break;
          case 403:
            error.value = "Accès non autorisé.";
            break;
          default:
            error.value = "Erreur lors de la récupération des données.";
        }
      } else if (error.request) {
        error.value = "Impossible de contacter le serveur.";
      } else {
        error.value = "Une erreur est survenue lors du chargement des données.";
      }
    };

    // When the component mounts, set the initial selected date to today and fetch data
    onMounted(() => {
      const today = new Date().toISOString().split("T")[0];   // Set to today as the default
      selectedStartDate.value = today;
      fetchChartData();                                       // Fetch the initial data based on today's date
    });

    return {
      chartData,
      chartOptions,
      selectedStartDate,
      fetchChartData,
      loadingMessage,
      totalHours,
      error
    };
  },
});
</script>

<style scoped>
.date-picker {
  margin-bottom: 20px;
}

.chart-container {
  width: 100%;
  height: 400px;
}

.total-hours {
  margin-top: 20px;
  font-size: 16px;
}
</style>
