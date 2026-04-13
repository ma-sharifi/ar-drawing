package com.ardrawing.controller;

import com.ardrawing.dto.TemplateResponse;
import com.ardrawing.model.Template;
import com.ardrawing.service.TemplateService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/templates")
@CrossOrigin(origins = "*")  // tighten in production
public class TemplateController {

    private final TemplateService service;

    public TemplateController(TemplateService service) {
        this.service = service;
    }

    /** GET /api/v1/templates  — list all, optional ?category=Animals */
    @GetMapping
    public List<TemplateResponse> list(
            @RequestParam(required = false) String category
    ) {
        if (category != null && !category.isBlank()) {
            return service.findByCategory(category);
        }
        return service.findAll();
    }

    /** GET /api/v1/templates/{id} */
    @GetMapping("/{id}")
    public ResponseEntity<TemplateResponse> getById(@PathVariable String id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * POST /api/v1/templates — upload new template metadata.
     * Actual SVG file upload is a separate endpoint (future feature).
     */
    @PostMapping
    public ResponseEntity<TemplateResponse> create(@RequestBody Template template) {
        return ResponseEntity.ok(service.save(template));
    }
}
