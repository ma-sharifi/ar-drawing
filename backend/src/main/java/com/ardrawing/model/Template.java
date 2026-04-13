package com.ardrawing.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "templates")
public class Template {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @NotBlank
    private String name;

    @NotBlank
    private String category;

    /** Path/filename of the SVG relative to the static templates directory */
    @NotBlank
    private String svgFilename;

    /** Optional rasterised thumbnail filename */
    private String thumbnailFilename;

    protected Template() {}

    public Template(String name, String category, String svgFilename, String thumbnailFilename) {
        this.name = name;
        this.category = category;
        this.svgFilename = svgFilename;
        this.thumbnailFilename = thumbnailFilename;
    }

    public String getId()                { return id; }
    public String getName()              { return name; }
    public String getCategory()          { return category; }
    public String getSvgFilename()       { return svgFilename; }
    public String getThumbnailFilename() { return thumbnailFilename; }
}
