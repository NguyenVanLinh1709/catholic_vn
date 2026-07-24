package com.churchhub;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.TimeZone;

@SpringBootApplication
public class ChurchHubApplication {

    public static void main(String[] args) {
        // Must run before Hibernate/the JDBC driver initialize. hibernate.jdbc.time_zone=UTC
        // (application.yml) is not consistently honored for plain TIME columns (mass_time):
        // some JDBC/Hibernate paths fall back to the JVM default zone for the java.sql.Time
        // <-> LocalTime conversion, which for Asia/Ho_Chi_Minh at the 1970-01-01 reference
        // epoch resolves to a historical +08:00 offset (Vietnam used +8 before 1975), not
        // today's +07:00 — silently shifting stored/read mass times by up to an hour depending
        // on JVM default TZ. Pinning the JVM default to UTC removes that ambiguity outright.
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
        SpringApplication.run(ChurchHubApplication.class, args);
    }
}
