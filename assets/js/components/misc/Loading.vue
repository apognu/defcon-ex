<template lang="pug">
  .text-center(v-if="!until")
    h2.mb-0 Loading data
    p Please wait while data is fetched...
  div(v-else)
    slot
      p Data is loaded.
</template>

<script>
export default {
  props: {
    until: {
      type: Boolean,
      default: false
    }
  }
};
</script>
