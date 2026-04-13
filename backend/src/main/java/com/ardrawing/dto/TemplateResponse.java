package com.ardrawing.dto;

import com.ardrawing.model.Template;

public record TemplateResponse(
        String id,
        String name,
        String category,
        String svgURL,
        String thumbnailURL
) {
    public static TemplateResponse from(Template t, String baseUrl) {
        String thumbnail = t.getThumbnailFilename() != null
                ? baseUrl + t.getThumbnailFilename()
                : null;
        return new TemplateResponse(
                t.getId(),
                t.getName(),
                t.getCategory(),
                baseUrl + t.getSvgFilename(),
                thumbnail
        );
    }
}
