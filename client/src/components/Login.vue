<template>
  <div class="min-h-screen flex items-center justify-center bg-image">
    <!-- Lightning Effects -->
    <div class="lightning-container">
      <div class="lightning-1"></div>
      <div class="lightning-2"></div>
      <div class="lightning-3"></div>
    </div>

    <!-- Main Content -->
    <div class="bg-zinc-800/90 backdrop-blur-sm rounded-lg shadow-2xl p-8 max-w-md w-full mx-4 space-y-8 relative">
      <div>
        <img class="mx-auto h-20 w-auto" src="@/assets/pngegg.png" alt="Logo Batman">
        <h2 id="login-title" class="mt-6 text-center text-3xl font-bold text-bat-yellow glow-text">
          Accès au Bat-Ordinateur
        </h2>
      </div>
      
      <form @submit.prevent="handleLogin" aria-labelledby="login-title" class="mt-8 space-y-6">
        <div class="rounded-md -space-y-px">
          <div>
            <label for="email" class="block text-bat-silver mb-2">Identifiant</label>
            <input
              type="email"
              id="email"
              v-model="email"
              required
              class="appearance-none rounded-t-md relative block w-full px-3 py-2 border border-bat-silver bg-black/50 text-bat-silver placeholder-bat-silver/70 focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow focus:z-10 sm:text-sm transition-all duration-200"
              placeholder="Entrez votre email"
              aria-describedby="email-error"
            >
          </div>
          <div>
            <label for="password" class="block text-bat-silver mb-2 mt-4">Code d'accès</label>
            <input
              type="password"
              id="password"
              v-model="password"
              required
              class="appearance-none rounded-b-md relative block w-full px-3 py-2 border border-bat-silver bg-black/50 text-bat-silver placeholder-bat-silver/70 focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow focus:z-10 sm:text-sm transition-all duration-200"
              placeholder="Entrez votre mot de passe"
              aria-describedby="password-error"
            >
          </div>
        </div>

        <div>
          <button
            type="submit"
            class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-bat-black bg-bat-yellow hover:bg-bat-yellow-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-bat-yellow transition-all duration-300 transform hover:scale-105"
            :disabled="isLoading"
            aria-busy="isLoading"
          >
            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
              <svg class="h-5 w-5 text-bat-yellow-dark group-hover:text-bat-yellow-light transition ease-in-out duration-150" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd" />
              </svg>
            </span>
            {{ isLoading ? 'Connexion en cours...' : 'Se connecter' }}
          </button>
        </div>
      </form>
      
      <div class="text-center">
        <p class="mt-2 text-sm text-bat-silver">
          Pas encore de compte ?
          <router-link to="/signup" class="font-medium text-bat-yellow hover:text-bat-yellow-light transition-colors duration-200">
            S'inscrire
          </router-link>
        </p>
      </div>

      <div v-if="Object.keys(errors).length > 0" 
           class="mt-4 bg-red-900/50 border border-red-400 text-red-200 px-4 py-3 rounded relative backdrop-blur-sm" 
           role="alert">
        <strong class="font-bold">Erreur ! </strong>
        <span class="block sm:inline">{{ errors.general || "Une erreur s'est produite. Veuillez réessayer." }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.bg-image {
  background-image: url('@/assets/gotham.png');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  position: relative;
  overflow: hidden;
}

/* Lightning Container and Effects */
.lightning-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.lightning-1, .lightning-2, .lightning-3 {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: transparent;
}

.lightning-1 {
  animation: lightning1 12s infinite;
}

.lightning-2 {
  animation: lightning2 15s infinite 1s;
}

.lightning-3 {
  animation: lightning3 18s infinite 2s;
}

@keyframes lightning1 {
  0% { background: transparent; }
  2% { background: rgba(255, 255, 255, 0.2); }
  3% { background: transparent; }
  6% { background: transparent; }
  8% { background: rgba(255, 255, 255, 0.2); }
  9% { background: transparent; }
  100% { background: transparent; }
}

@keyframes lightning2 {
  0% { background: transparent; }
  1% { background: rgba(255, 255, 255, 0.2); }
  2% { background: transparent; }
  4% { background: transparent; }
  6% { background: rgba(255, 255, 255, 0.2); }
  7% { background: transparent; }
  100% { background: transparent; }
}

@keyframes lightning3 {
  0% { background: transparent; }
  3% { background: rgba(255, 255, 255, 0.2); }
  4% { background: transparent; }
  7% { background: transparent; }
  9% { background: rgba(255, 255, 255, 0.2); }
  10% { background: transparent; }
  100% { background: transparent; }
}

.glow-text {
  text-shadow: 
    0 0 10px rgba(255, 238, 31, 0.7),
    0 0 20px rgba(255, 238, 31, 0.5),
    0 0 30px rgba(255, 238, 31, 0.3);
}

/* Input focus effects */
input:focus {
  box-shadow: 0 0 10px rgba(255, 238, 31, 0.3);
}

/* Button hover effect */
button:hover {
  box-shadow: 0 0 15px rgba(255, 238, 31, 0.4);
}

/* Responsive adjustments */
@media (max-width: 640px) {
  .bg-image {
    background-position: center;
  }
}
</style>

<script>
import api from '@/services/api_token';

export default {
  name: 'Log-in',
  data() {
    return {
      email: '',
      password: '',
      errors: {},
      isLoading: false
    }
  },
  methods: {
    async handleLogin() {
      this.errors = {};
      this.isLoading = true;

      try {
        const response = await api.post('/auth/login', {
          email: this.email,
          password: this.password
        });

        console.log('RESPONSE', response);
        const { token, user } = response.data;

        // Store authentication data
        localStorage.setItem('token', token);
        localStorage.setItem('role', user.role);
        localStorage.setItem('userId', user.id);
        
        // Fetch complete user info
        const userDetails = await this.getUserDetails(user.id);
        if (userDetails) {
          // Store complete user info
          localStorage.setItem('userEmail', userDetails.email);
          localStorage.setItem('userName', userDetails.username || '');
          localStorage.setItem('userDetails', JSON.stringify(userDetails));
        }
        
        console.log(`Utilisateur connecté avec le rôle : ${user.role}`);

        // Redirect based on role with user info
        this.redirectBasedOnRole(user.role);
      } catch (error) {
        console.error('Erreur de connexion:', error);
        this.handleLoginError(error);
      } finally {
        this.isLoading = false;
      }
    },

    async getUserDetails(userId) {
      try {
        const response = await api.get(`/users/${userId}`);
        console.log('User Details:', response.data);
        return response.data.data;
      } catch (error) {
        console.error('Erreur lors de la récupération des détails utilisateur:', error);
        this.handleError(error, "la récupération des détails utilisateur");
        return null;
      }
    },

    redirectBasedOnRole(role) {
      const roleRoutes = {
        'employee': '/employee-dashboard',
        'manager': '/manager-dashboard',
        'general_manager': '/general-manager-dashboard',
        'admin': '/admin-dashboard'
      };

      const route = roleRoutes[role] || '/';
      this.$router.push({
        path: route,
        query: { 
          fromLogin: 'true'
        }
      });
    },

    handleLoginError(error) {
      if (error.response) {
        const status = error.response.status;
        switch (status) {
          case 401:
            this.errors = { 
              general: "Identifiants incorrects. Veuillez vérifier votre email et mot de passe." 
            };
            break;
          case 403:
            this.errors = { 
              general: "Accès non autorisé." 
            };
            break;
          case 404:
            this.errors = { 
              general: "Service d'authentification non disponible." 
            };
            break;
          case 422:
            this.errors = { 
              general: "Données invalides. Veuillez vérifier vos informations." 
            };
            break;
          default:
            this.errors = { 
              general: "Une erreur s'est produite lors de la connexion. Veuillez réessayer." 
            };
        }
        console.log('Détails de l\'erreur:', error.response.data);
      } else if (error.request) {
        this.errors = { 
          general: "Impossible de contacter le serveur. Veuillez vérifier votre connexion."
        };
      } else {
        this.errors = { 
          general: "Une erreur inattendue s'est produite. Veuillez réessayer."
        };
      }
    }
  },

  // Clear any stored auth data when component is mounted
  mounted() {
    localStorage.removeItem('token');
    localStorage.removeItem('role');
    localStorage.removeItem('userId');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userName');
    localStorage.removeItem('userDetails');
  }
}
</script>