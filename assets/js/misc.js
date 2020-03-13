export default {
  formatDate: (date) => {
    const options = {
      dateStyle: 'full',
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: 'numeric',
      hour12: false,
      minute: 'numeric'
    };

    const formatter = new Intl.DateTimeFormat('en', options);

    return formatter.format(date);
  },

  formatCustomDate: (date, style) => {
    const options = { dateStyle: 'full', hour12: false };

    switch (style) {
      case 'day':
        options.weekday = 'short';
        options.day = 'numeric';
        options.month = 'short';
        break;

      case 'month':
        options.month = 'short';
        options.year = 'numeric';
        break;

      default:
        options.day = 'numeric';
        options.month = 'short';
        options.year = 'numeric';
        options.hour = 'numeric';
        options.minute = 'numeric';
        options.second = 'numeric';
    }

    const formatter = new Intl.DateTimeFormat('en', options);

    return formatter.format(date);
  }
};
