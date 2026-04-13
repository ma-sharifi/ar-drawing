package com.ardrawing.service;

import com.ardrawing.dto.TemplateResponse;
import com.ardrawing.model.Template;
import com.ardrawing.repository.TemplateRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class TemplateService {

    private final TemplateRepository repository;
    private final String baseUrl;

    public TemplateService(
            TemplateRepository repository,
            @Value("${app.templates.base-url}") String baseUrl
    ) {
        this.repository = repository;
        this.baseUrl = baseUrl;
    }

    public List<TemplateResponse> findAll() {
        return repository.findAll()
                .stream()
                .map(t -> TemplateResponse.from(t, baseUrl))
                .toList();
    }

    public List<TemplateResponse> findByCategory(String category) {
        return repository.findByCategory(category)
                .stream()
                .map(t -> TemplateResponse.from(t, baseUrl))
                .toList();
    }

    public Optional<TemplateResponse> findById(String id) {
        return repository.findById(id)
                .map(t -> TemplateResponse.from(t, baseUrl));
    }

    public TemplateResponse save(Template template) {
        return TemplateResponse.from(repository.save(template), baseUrl);
    }
}
