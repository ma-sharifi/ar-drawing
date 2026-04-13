package com.ardrawing.config;

import com.ardrawing.model.Template;
import com.ardrawing.repository.TemplateRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

/** Seeds the DB with sample templates on startup (dev / demo only). */
@Component
public class DataSeeder implements CommandLineRunner {

    private final TemplateRepository repository;

    public DataSeeder(TemplateRepository repository) {
        this.repository = repository;
    }

    @Override
    public void run(String... args) {
        if (repository.count() > 0) return;

        repository.save(new Template("Train",   "Vehicles",  "train.svg",  "train.png"));
        repository.save(new Template("Cat",     "Animals",   "cat.svg",    "cat.png"));
        repository.save(new Template("House",   "Buildings", "house.svg",  "house.png"));
        repository.save(new Template("Star",    "Shapes",    "star.svg",   "star.png"));
        repository.save(new Template("Dog",     "Animals",   "dog.svg",    null));
        repository.save(new Template("Rocket",  "Vehicles",  "rocket.svg", null));
    }
}
