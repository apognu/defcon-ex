<template lang="pug">
  Loading(:until="status !== undefined")
    div(v-if="status")
      h2 Dashboard

      Status(:outages="status.outages" :show-cta="true")

      .block.pb
        .row
          .col-md-4
            Graph(title="Last week" type="squares b-7" :data="status.stats_1w" date-style="day" range="day")

          .col-md-8.uptime-graph-pill-container
            Graph(title="Last 72 hours" type="pills" :data="status.stats_72h" range="hour")

        .row.mt-4
          .col-12
            Graph(title="Last year" type="squares b-12" :data="status.stats_1y" date-style="month" range="month")
</template>

<script>
import axios from 'axios';
import Loading from '@/components/misc/Loading';
import Status from '@/components/misc/Status';
import Graph from './Graph';

export default {
  components: { Loading, Status, Graph },

  data: () => ({
    interval: null,
    status: undefined,
  }),

  async mounted() {
    this.getStatus();
    setInterval(this.getStatus, 10000);
  },

  destroyed() {
    clearInterval(this.interval);
  },

  methods: {
    getStatus() {
      axios
        .get('/api/dashboard')
        .then((response) => (this.status = response.data));
    },
  },
};
</script>
