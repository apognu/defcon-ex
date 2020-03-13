<template lang="pug">
  div
    h2 Edit check

    div(@keyup.enter="saveCheck")
      .form-group.text-right
        .pretty.p-switch.p-fill
          input#enabled(type="checkbox" v-model="data.check.enabled")
          .state
            label(for="enabled") Enable check

      .block
        .row: .col: h3 Classification

        .row
          .col
            .form-group
              label(for="title") Check title:
              input#title.form-control(type="text" v-model="data.check.title")

          .col
            .form-group
              label(for="group_id") Check group:
              select#group_id.custom-select(v-model="data.check.group.id")
                option(value="") No group...
                option(v-for="group in groups" :value="group.id") {{group.title}}

        .row: .col: h3 Threshold

        .row
          .col
            .form-group
              label(for="failing_threshold") Failing threshold:
              input#failing_threshold.form-control(type="number" v-model="data.check.failing_threshold")
              small.form-text.text-muted Service will be considered critical after this number of failed checks

          .col
            .form-group
              label(for="passing_threshold") Recovery threshold:
              input#passing_threshold.form-control(type="number" v-model="data.check.passing_threshold")
              small.form-text.text-muted Outage will be considered resolved after this number of passed checks

          .col
            .form-group
              label(for="interval") Check interval (in seconds):
              input#interval.form-control(type="number" v-model="data.check.interval")

        .row
          .col
            .form-group
              label(for="kind") Check type:
              select#kind.custom-select(v-model="data.check.kind")
                option(value="") Select a type...
                option(v-for="(kind, id) of kinds" :value="id") {{kind}}

          .col
            .form-group
              label(for="alerter") Alerter:
              select#alerter.custom-select(v-model="data.check.alerter.id")
                option(value="") No alerter...
                option(v-for="alerter in alerters" :value="alerter.id") {{alerter.title}}

      .form-group.text-right
        .pretty.p-switch.p-fill
          input#ignore(type="checkbox" v-model="data.check.ignore")
          .state
            label(for="ignore") Ignore this check for uptime calculations

      component(v-if="data.check.kind" :is="getCheckComponent()")

      button.btn.btn-primary(@click="saveCheck") Save check
</template>

<script>
import axios from 'axios';

import SpecAppStore from './specs/AppStore';
import SpecPlayStore from './specs/PlayStore';
import SpecHttp from './specs/Http';
import SpecTcp from './specs/Tcp';
import SpecTls from './specs/Tls';
import SpecCrt from './specs/Crt';

export default {
  components: { SpecAppStore, SpecPlayStore, SpecHttp, SpecTcp, SpecTls, SpecCrt },

  data: () => ({
    kinds: {},
    alerters: [],
    groups: [],
    data: {
      check: {
        group: {
          id: ''
        },
        alerter: {
          id: ''
        }
      }
    }
  }),

  async mounted() {
    axios
      .get('/api/checks/kinds')
      .then(response => this.kinds = response.data);

    axios
      .get('/api/alerters')
      .then(response => this.alerters = response.data);

    axios
      .get('/api/groups')
      .then(response => this.groups = response.data.groups);

    if (this.$route.meta.new) {
      this.initSpecs();

      this.data.check.enabled = true;
      this.data.check.ignore = false;
      this.data.check.alerter = this.data.check.alerter || { id: '' };
      this.data.check.group = this.data.check.group || { id: '' };
    } else {
      axios
        .get(`/api/checks/${this.$route.params.id}`)
        .then(response => {
          this.data = response.data;
          this.data.check.alerter = this.data.check.alerter || { id: '' };
          this.data.check.group = this.data.check.group || { id: '' };
          this.initSpecs;
        });
    }
  },

  methods: {
    initSpecs() {
      this.data.check.app_store_spec = this.data.check.app_store_spec || {};
      this.data.check.play_store_spec = this.data.check.play_store_spec || {};
      this.data.check.http_spec = this.data.check.http_spec || {};
      this.data.check.tcp_spec = this.data.check.tcp_spec || {};
      this.data.check.tls_spec = this.data.check.tls_spec || {};
      this.data.check.crt_spec = this.data.check.crt_spec || {};
    },

    getCheckComponent() {
      switch (this.data.check.kind) {
        case 'app_store': return SpecAppStore;
        case 'play_store': return SpecPlayStore;
        case 'http': return SpecHttp;
        case 'tcp': return SpecTcp;
        case 'tls': return SpecTls;
        case 'crt': return SpecCrt;
        default: return null;
      }
    },

    saveCheck() {
      const body = {
        check: {
          enabled: this.data.check.enabled,
          title: this.data.check.title,
          group_id: this.data.check.group.id,
          failing_threshold: this.data.check.failing_threshold,
          passing_threshold: this.data.check.passing_threshold,
          interval: this.data.check.interval,
          kind: this.data.check.kind,
          alerter_id: this.data.check.alerter.id,
          ignore: this.data.check.ignore
        }
      };

      body.check[`${this.data.check.kind}_spec`] = this.data.check[`${this.data.check.kind}_spec`];

      if (this.$route.meta.new) {
        axios
          .post(`/api/checks`, body)
          .then(_ => this.$router.push({ name: 'checks' }));
      } else {
        axios
          .put(`/api/checks/${this.data.check.uuid}`, body)
          .then(_ => this.$router.push({ name: 'checks' }));
      }
    }
  }
};
</script>
