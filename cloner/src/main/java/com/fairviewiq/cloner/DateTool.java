package com.fairviewiq.cloner;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Locale;

/**
 *
 * @author henrik
 */
public class DateTool {

    private ArrayList<DateFormat> possibleFormat = new ArrayList<DateFormat>(5);
    private int currentIndex = 0;
    private static DateTool instance = null;
    private Locale locale = Locale.getDefault();

    private DateTool() {

        possibleFormat.add(new SimpleDateFormat("yyMMdd"));
        possibleFormat.add(new SimpleDateFormat("yyyyMMdd"));
        possibleFormat.add(new SimpleDateFormat("yyyy MM dd"));
        possibleFormat.add(new SimpleDateFormat("dd MMM yyyy"));

    }

    public static DateTool getInstance(Locale locale) {

        DateTool retval = getInstance();

        retval.setLocale(locale);

        return retval;

    }

    public static DateTool getInstance() {

        if (instance == null) {
            instance = new DateTool();
        }

        return instance;

    }

    private void setLocale(Locale locale) {

        this.locale = locale;

    }

    private DateFormat getNextFormat(int length) {

        DateFormat retval = possibleFormat.get(currentIndex++);

        if (currentIndex > possibleFormat.size()) {
            currentIndex = 0;
        }

        if (retval.format(new Date(System.currentTimeMillis())).length() != length) {

            retval = getNextFormat(length);

        }

        retval.setLenient(false);

        return retval;

    }

    private Date getDateFromWeekString(String weekString) {

        Date retval = null;
        GregorianCalendar calendar = new GregorianCalendar(locale);

        try {

            String[] weekAndYearArray = (weekString + ",").substring(1).split(",");
            int week = Integer.parseInt(weekAndYearArray[0].replaceAll("\\D", ""));

            if (week > 53) {
                week = 53;
            }

            int year = 0;

            if (weekAndYearArray.length > 1) {

                try {

                    year = Integer.parseInt(weekAndYearArray[1].replaceAll("\\D", ""));

                } catch (Exception ex) {
                }

            }

            if (year == 0 && week > calendar.get(Calendar.WEEK_OF_YEAR)) {

                year = calendar.get(Calendar.YEAR) - 1;

            } else if (year == 0) {

                year = calendar.get(Calendar.YEAR);

            }

            calendar.set(Calendar.YEAR, year);
            calendar.set(Calendar.WEEK_OF_YEAR, week);
            calendar.set(Calendar.DAY_OF_WEEK, 1);

            retval = calendar.getTime();

        } catch (Exception ex) {
        } finally {
            return retval;
        }

    }

    public Date guessDate(String dateString) {

        Date retval = null;

        if (dateString.substring(0, 1).equalsIgnoreCase("v") || dateString.substring(0, 1).equalsIgnoreCase("w")) {

            retval = getDateFromWeekString(dateString);
//            retval = getDateFromWeek(Integer.getInteger(weekAndYearArray[1]), currentIndex)
        } else {

            try {

                String compactDateString = dateString.replaceAll("-", "");

                retval = getNextFormat(compactDateString.length()).parse(compactDateString);

            } catch (Exception ex) {
                ex.printStackTrace();
                if (currentIndex < possibleFormat.size()) {
                    retval = guessDate(dateString);
                }

            } finally {
                currentIndex = 0;
            }

        }

        return retval;

    }
}
