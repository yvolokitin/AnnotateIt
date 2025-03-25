String formatDate(DateTime date) {
  return "${date.day} ${getMonthName(date.month)} ${date.year} | ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
}

String getMonthName(int month) {
  const months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  return months[month - 1];
}
