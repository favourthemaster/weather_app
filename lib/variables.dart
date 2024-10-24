class Variables {
  static String getStringTime(DateTime time) {
    int hour = time.hour;
    if (hour < 12) {
      return "${hour}AM";
    } else {
      return "${hour - 12}PM";
    }
  }

  static String getFullStringTime(DateTime time) {
    int hour = time.hour;
    int minutes = time.minute;
    if (minutes < 10) {
      if (hour < 12) {
        return "$hour:0$minutes AM";
      } else {
        return "${hour - 12}:0$minutes PM";
      }
    } else {
      if (hour == 0) {
        return "12:$minutes AM";
      } else if (hour == 12) {
        return "12:$minutes PM";
      } else if (hour < 12) {
        return "$hour:$minutes AM";
      } else {
        return "${hour - 12}:$minutes PM";
      }
    }
  }

  static String getStringDate(DateTime date) {
    int day = date.day;
    int dayOfWeek = date.weekday;
    int month = date.month;
    String? monthString;
    String? dayString;
    switch (dayOfWeek) {
      case 1:
        dayString = "Monday";
        break;
      case 2:
        dayString = "Tuesday";
        break;
      case 3:
        dayString = "Wednesday";
        break;
      case 4:
        dayString = "Thursday";
        break;
      case 5:
        dayString = "Friday";
        break;
      case 6:
        dayString = "Saturday";
        break;
      case 7:
        dayString = "Sunday";
        break;
    }

    switch (month) {
      case 1:
        monthString = "January";
        break;
      case 2:
        monthString = "February";
        break;
      case 3:
        monthString = "March";
        break;
      case 4:
        monthString = "April";
        break;
      case 5:
        monthString = "May";
        break;
      case 6:
        monthString = "June";
        break;
      case 7:
        monthString = "July";
        break;
      case 8:
        monthString = "August";
        break;
      case 9:
        monthString = "September";
        break;
      case 10:
        monthString = "October";
        break;
      case 11:
        monthString = "November";
        break;
      case 12:
        monthString = "December";
        break;
    }
    return "$day $monthString, $dayString";
  }
}
