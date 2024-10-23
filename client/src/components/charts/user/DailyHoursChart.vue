<template>
    <div class="bg-bat-gray rounded-lg shadow-bat p-6">
        <h2 class="text-1xl font-bold mb-6 text-bat-yellow">Daily Hours Chart</h2>

        <!-- Date picker to select the start of the week -->
        <div class="date-picker">
            <label for="start-date" class="block text-sm font-medium text-bat-silver mb-1">Select Start Date:</label>
            <input type="date" id="start-date" v-model="selectedStartDate" @change="fetchChartData" class="px-3 py-2 bg-bat-gray border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow" />
        </div>

        <!-- Chart container -->
        <div class="chart-container">
            <BarChart v-if="chartData" :chart-data="chartData" :options="chartOptions" />
            <p v-else>{{ loadingMessage }}</p>
        </div>
    
        <!-- Total hours worked for the week -->
        <div v-if="totalHours !== null" class="total-hours">
            <p>Total hours worked for the week: <strong>{{ totalHours }}</strong></p>
        </div>
    </div>
</template>
  
<script>
    import { defineComponent, ref, onMounted } from "vue";
    import { useRoute } from "vue-router";
    import { BarChart } from "vue-chart-3";
    import axios from "axios";
    import "chart.js/auto";
import api from "@/services/api";
  
    export default defineComponent({
      components: {
        BarChart,
      },
      setup() {
        const chartData = ref(null);
        const loadingMessage = ref("Loading chart...");
        const totalHours = ref(null);  // For holding the total hours worked for the week
        const chartOptions = ref({
          responsive: true,
          scales: {
            y: {
              beginAtZero: true,
              title: {
                display: true,
                text: "Hours Worked",
              },
            },
            x: {
              title: {
                display: true,
                text: "Days of the Week",
              },
            },
          },
        });
  
        const route = useRoute();
        const userId = ref(route.query.id);
        const selectedStartDate = ref(null); // For the date picker
  
        // Function to fetch chart data
        const fetchChartData = async () => {
          try {
            if (!selectedStartDate.value) {
              loadingMessage.value = "Please select a start date.";
              return;
            }
  
            const startDate = selectedStartDate.value;
            const currentWeekDates = getCurrentWeekDates(startDate); // Get the week's dates based on the selected start date
            const endDate = currentWeekDates[6];  // End date is 6 days after start date
  
            console.log(`Fetching data for user ID: ${userId.value}, from ${startDate} to ${endDate}`);
  
            // Fetch the weekly data from the backend
            const response = await api.get("/reports/weekly_hours", {
              params: { user_id: userId.value, start_date: startDate, end_date: endDate },
              headers: { 'Accept': 'application/json' }
            });

            console.log("API Response:", response.data);
  
            if (typeof response.data === 'string' && response.data.includes('<!DOCTYPE html>')) {
              throw new Error('Received HTML instead of JSON. Check API endpoint and server configuration.');
            }
  
            const hoursByDay = response.data.hours_by_day || {};
            const labels = currentWeekDates.map(date => formatDateToLabel(date));
  
            const hoursWorked = labels.map((label, index) => {
              const date = currentWeekDates[index]; // Use the ISO format for data lookup
              const hours = hoursByDay[date] || 0;
              return hours;
            });
  
            // Calculate total hours worked for the week
            totalHours.value = hoursWorked.reduce((total, hours) => total + hours, 0);
  
            chartData.value = {
              labels, // Use formatted labels
              datasets: [
                {
                  label: "Hours Worked",
                  backgroundColor: "#42A5F5",
                  data: hoursWorked,
                },
              ],
            };
          } catch (error) {
            console.error("Error fetching chart data:", error);
            loadingMessage.value = "Error loading chart data. Please try again later.";
          }
        };
  
        // Helper function to get dates for the week based on the selected start date
        const getCurrentWeekDates = (startDate) => {
          const start = new Date(startDate);
          const dates = [];
          for (let i = 0; i < 7; i++) {
            const date = new Date(start);
            date.setDate(start.getDate() + i);  // Calculate each date (Monday to Sunday)
            dates.push(date.toISOString().split('T')[0]);  // Format as YYYY-MM-DD
          }
          return dates;
        };
  
        // Helper function to format the date as "MMM DD, YYYY" (e.g., "Oct 15, 2024")
        const formatDateToLabel = (dateString) => {
          const date = new Date(dateString);
          const formatter = new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
          return formatter.format(date);
        };
  
        // When the component mounts, set the initial selected date to today (if needed)
        onMounted(() => {
          const today = new Date().toISOString().split('T')[0]; // Set to today as the default
          selectedStartDate.value = today;
          fetchChartData();  // Fetch the initial data based on today's date
        });
  
        return {
          chartData,
          chartOptions,
          selectedStartDate,
          fetchChartData,
          loadingMessage,
          totalHours,
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
  