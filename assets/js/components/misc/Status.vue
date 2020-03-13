<template lang="pug">
div
  .placeholder.alert.pt-4(v-if="ok")
    .status.mb-3: .led.status-operational
    h4 Breath in
    p Everything seems to be going okay
  slot(v-else-if="ko")
    .placeholder.pt-4
      .status.mb-3: .led.status-outages
      h4 {{outages}} checks failing
      p Some of your services require your attention
      p(v-if="showCta"): router-link(to="/outages" class="btn btn-secondary btn-sm") See outages
</template>

<script>
export default {
  props: {
    showOk: {
      type: Boolean,
      default: true
    },
    showKo: {
      type: Boolean,
      default: true
    },
    showCta: {
      type: Boolean,
      default: false
    },
    outages: {
      type: Number,
      default: 0
    }
  },

  computed: {
    ok() {
      return this.outages == 0 && this.showOk;
    },

    ko() {
      return this.outages > 0 && this.showKo;
    }
  }
};
</script>

<style scoped lang="scss">
.placeholder {
  clear: both;
}
</style>
