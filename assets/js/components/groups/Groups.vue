<template lang="pug">
  div
    router-link(to="/groups/new" class="float-right btn btn-secondary") New group

    h2 Groups

    Loading(:until="data !== undefined")
      .block(v-if="data")
        table.table
          thead.thead-light
            tr
              th
              th.fill Group title
              th # of checks
              th Outages
              th.fit

          tbody
            tr(v-for="group in data.groups" :class="{ 'table-danger': data.outages[group.id] > 0 }")
              td
                .status
                  .led.status-outages(v-if="data.outages[group.id] > 0")
                  .led.status-operational(v-else)
              td {{group.title}}
              td {{group.checks.length}} checks
              td
              td.actions
                router-link(:to="{ name: 'groups.edit', params: { id: group.uuid } }" class="btn btn-secondary btn-sm mr-1") Edit
                a.btn.btn-danger.btn-sm(href="#" @click="deleteGroup(group)") Delete
</template>

<script>
import axios from 'axios';
import Loading from '@/components/misc/Loading';

export default {
  components: { Loading },

  data: () => ({
    data: undefined
  }),

  async mounted() {
    this.getGroups();
  },

  methods: {
    getGroups() {
      axios
        .get('/api/groups')
        .then(response => {
          this.data = response.data;
        });
    },

    deleteGroup(group) {
      axios
        .delete(`/api/groups/${group.uuid}`)
        .then(_ => this.getGroups());
    }
  }
};
</script>
