<template lang="pug">
  div
    .navbar.navbar-expand-lg.navbar-dark.bg-dark
      router-link(to="/" class="navbar-brand") Defcon

      ul.navbar-nav
        li.nav-item: router-link(to="/" class="nav-link") Dashboard
        li.nav-item: router-link(to="/outages" class="nav-link") Outages

        li.nav-item.dropdown
          a#navbar-settings.nav-link.dropdown-toggle(href="#" data-toggle="dropdown") Settings
          .dropdown-menu
            router-link(to="/groups" class="dropdown-item") Groups
            router-link(to="/checks" class="dropdown-item") Checks
            router-link(to="/alerters" class="dropdown-item") Alerters

      .status.navbar-text.mr-auto
        template(v-if="status.outages > 0")
          span.led.status-outages
          | Some systems critical
        template(v-else)
          span.led.status-operational
          | All systems operational

    #content.container
      router-view
</template>

<script>
import axios from 'axios';

export default {
  data: () => ({
    interval: null,
    status: {}
  }),

  async mounted() {
    this.getStatus();
    this.interval = setInterval(this.getStatus, 10000);
  },

  destroyed() {
    if (this.interval !== null) clearInterval(this.internal);
  },

  methods: {
    getStatus: function() {
      axios
        .get('/api/dashboard')
        .then(response => {
          this.status = response.data;
        });
    }
  }
};
</script>

<style scoped lang="scss">
.navbar {
  display: flex;

  .status {
    padding: .5rem 1rem;
    color: white;
  }
}

.status {
  .led {
    display: inline-block;
    margin-right: 8px;
    width: 10px;
    height: 10px;
    border-radius: 5px;

    &.status-outages {
      background: map-get($theme-colors, "danger");
    }

    &.status-operational {
      background: map-get($theme-colors, "success");
    }
  }
}
</style>
