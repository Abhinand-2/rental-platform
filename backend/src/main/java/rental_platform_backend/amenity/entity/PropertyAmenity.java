package rental_platform_backend.amenity.entity;

import rental_platform_backend.property.entity.Property;
import jakarta.persistence.*;

@Entity
@Table(name = "property_amenities")
public class PropertyAmenity {

    @EmbeddedId
    private PropertyAmenityId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("propertyId")
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("amenityId")
    @JoinColumn(name = "amenity_id", nullable = false)
    private Amenity amenity;

    public PropertyAmenity() {
    }

    public PropertyAmenity(
            PropertyAmenityId id,
            Property property,
            Amenity amenity
    ) {
        this.id = id;
        this.property = property;
        this.amenity = amenity;
    }

    public PropertyAmenityId getId() {
        return id;
    }

    public Property getProperty() {
        return property;
    }

    public Amenity getAmenity() {
        return amenity;
    }
}