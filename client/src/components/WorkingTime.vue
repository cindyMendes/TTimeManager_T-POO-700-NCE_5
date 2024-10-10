<template>
  <div class="flex flex-col items-center justify-center min-h-screen bg-gray-100 p-4">
    <div class="bg-white p-6 rounded-lg shadow-md w-full max-w-2xl">
      <h1 class="text-2xl font-bold mb-6 text-center">Management des Working Times</h1>

      <!-- Button to fetch working times -->
      <button @click="getWorkingTimesByUserId" class="bg-blue-500 text-white font-bold py-2 px-4 rounded mb-6 w-full hover:bg-blue-600">
        Load Working Times
      </button>

      <!-- Display existing working times IDs in a grid -->
      <div v-if="workingTimes.length">
        <h2 class="text-xl font-bold mb-4">Working Times:</h2>
        <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
          <div
            v-for="(time, index) in workingTimes"
            :key="index"
            @click="selectWorkingTime(time.id)"
            :class="['border p-2 cursor-pointer text-center', { 'selected-cell': selectedWorkingTime && selectedWorkingTime.id === time.id }]"
          >
            {{ time.id }}
          </div>
        </div>
      </div>
      <div v-else>
        <p class="text-gray-500">No working times available.</p>
      </div>

      <!-- Display selected working time details in update format -->
      <div v-if="selectedWorkingTime" class="mt-6">
        <h2 class="text-xl font-bold mb-4">Selected Working Time:</h2>
        <div class="flex flex-col sm:flex-row items-center mb-4">
          <input v-model="startTime" type="datetime-local" class="mr-2 p-2 border rounded mb-2 sm:mb-0" />
          <input v-model="endTime" type="datetime-local" class="mr-2 p-2 border rounded mb-2 sm:mb-0" />
          <button @click="updateWorkingTime({ working_time: { start: startTime, end: endTime } })" :disabled="!timesChanged" :class="{ 'deactivated-button': !timesChanged }" class="bg-green-500 text-white font-bold py-2 px-4 rounded hover:bg-green-600 disabled:opacity-50">
            Update Working Time
          </button>
        </div>
      </div>

      <!-- Existing form and buttons -->
      <div class="flex flex-col sm:flex-row items-center mb-4">
        <input v-model="startTime" type="datetime-local" class="mr-2 p-2 border rounded mb-2 sm:mb-0" />
        <input v-model="endTime" type="datetime-local" class="mr-2 p-2 border rounded mb-2 sm:mb-0" />
        <button @click="createWorkingTime({ working_time: { start: startTime, end: endTime } })" class="bg-blue-500 text-white font-bold py-2 px-4 rounded hover:bg-blue-600">
          Create Working Time
        </button>
      </div>
      <button @click="deleteWorkingTime()" class="bg-red-500 text-white font-bold py-2 px-4 rounded w-full hover:bg-red-600">
        Delete Working Time
      </button>
    </div>
  </div>
</template>
  
  <script>
  import axios from 'axios';
  
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
  data() {
    return {
      user_id: '1',
      workingTimes: [],
      selectedWorkingTime: null,
      startTime: '',
      endTime: '',
      startTimeCreate: '',
      endTimeCreate: ''
    };
  },
  computed: {
    timesChanged() {
      if (!this.selectedWorkingTime) return false;
      return this.startTime !== this.formatDateTime(this.selectedWorkingTime.start) || this.endTime !== this.formatDateTime(this.selectedWorkingTime.end);
    }
  },
    methods: {
      async getWorkingTimesByUserId() {
        try {
          const response = await fetch(`http://localhost:4000/api/workingtimes/${this.user_id}?start=2022-10-08T09:00:00Z&end=2024-10-08T17:00:00Z`);
          const data = await response.json();
          this.workingTimes = data.data;
          console.log('Working times for user {{this.userId}}:', this.workingTimes);
        } catch (error) {
          console.error('Error getting working time:', error);
        }
      },
      async createWorkingTime(data) {
        try {
          const response = await axios.post(`http://localhost:4000/api/workingtime/${this.user_id}`, data);
          this.getWorkingTimesByUserId();
          console.log('Working time created:', response.data);
        } catch (error) {
          console.error('Error creating working time:', error);
        }
      },
      async updateWorkingTime(data) {
        try {
          const response = await axios.put(`http://localhost:4000/api/workingtime/${this.selectedWorkingTime.id}`, data);
          this.getWorkingTimesByUserId();
          console.log('Working time updated:', response.data);
        } catch (error) {
          console.error('Error updating working time:', error);
        }
      },
      async deleteWorkingTime() {
        try {
          const response = await axios.delete(`http://localhost:4000/api/workingtime/${this.selectedWorkingTime.id}`);
          this.getWorkingTimesByUserId();
          this.selectedWorkingTime = null; // Clear the selected working time
          this.startTime = ''; // Reset the start time picker
          this.endTime = ''; // Reset the end time picker
          console.log('Working time deleted:', response.data);
        } catch (error) {
          console.error('Error deleting working time:', error);
        }
      },
      formatDateTime(datetime) {
        return datetime.slice(0, 16);
      },
      selectWorkingTime(id) {
        const selected = this.workingTimes.find(time => time.id === id);
        this.selectedWorkingTime = selected;
        this.startTime = this.formatDateTime(selected.start);
        this.endTime = this.formatDateTime(selected.end);
      },
    },
    created() {
      this.getWorkingTimesByUserId();
    }
  };
  </script>
  
  <style scoped>
  .grid {
    display: grid;
    gap: 1rem;
  }
  .cursor-pointer {
    cursor: pointer;
  }
  .selected-cell {
    background-color: grey;
    color: white;
    font-weight: bold;
  }
  .deactivated-button {
    color: grey;
  }
  </style>
  