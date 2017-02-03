//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vJAXB 2.1.3 in JDK 1.6 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2009.09.29 at 09:13:32 AM EDT 
//


package gov.noaa.nws.ncep.gempak.parameters.core.marshaller.garea;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element ref="{}geog_code" minOccurs="0"/>
 *         &lt;element ref="{}geog_area_name" minOccurs="0"/>
 *         &lt;element ref="{}center_lat" minOccurs="0"/>
 *         &lt;element ref="{}center_lon" minOccurs="0"/>
 *         &lt;element ref="{}lower_left_lat" minOccurs="0"/>
 *         &lt;element ref="{}lower_left_lon" minOccurs="0"/>
 *         &lt;element ref="{}upper_right_lat" minOccurs="0"/>
 *         &lt;element ref="{}upper_right_lon" minOccurs="0"/>
 *         &lt;element ref="{}map_projection_string" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "geogCode",
    "geogAreaName",
    "centerLat",
    "centerLon",
    "lowerLeftLat",
    "lowerLeftLon",
    "upperRightLat",
    "upperRightLon",
    "mapProjectionString"
})
@XmlRootElement(name = "geographical_data")
public class GeographicalData {

    @XmlElement(name = "geog_code")
    protected String geogCode;
    @XmlElement(name = "geog_area_name")
    protected String geogAreaName;
    @XmlElement(name = "center_lat")
    protected Float centerLat;
    @XmlElement(name = "center_lon")
    protected Float centerLon;
    @XmlElement(name = "lower_left_lat")
    protected Float lowerLeftLat;
    @XmlElement(name = "lower_left_lon")
    protected Float lowerLeftLon;
    @XmlElement(name = "upper_right_lat")
    protected Float upperRightLat;
    @XmlElement(name = "upper_right_lon")
    protected Float upperRightLon;
    @XmlElement(name = "map_projection_string")
    protected String mapProjectionString;

    /**
     * Gets the value of the geogCode property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGeogCode() {
        return geogCode.trim();
    }

    /**
     * Sets the value of the geogCode property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGeogCode(String value) {
        this.geogCode = value.trim();
    }

    /**
     * Gets the value of the geogAreaName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGeogAreaName() {
        return geogAreaName.trim();
    }

    /**
     * Sets the value of the geogAreaName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGeogAreaName(String value) {
        this.geogAreaName = value.trim();
    }

    /**
     * Gets the value of the centerLat property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getCenterLat() {
        return centerLat;
    }

    /**
     * Sets the value of the centerLat property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setCenterLat(Float value) {
        this.centerLat = value;
    }

    /**
     * Gets the value of the centerLon property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getCenterLon() {
        return centerLon;
    }

    /**
     * Sets the value of the centerLon property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setCenterLon(Float value) {
        this.centerLon = value;
    }

    /**
     * Gets the value of the lowerLeftLat property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getLowerLeftLat() {
        return lowerLeftLat;
    }

    /**
     * Sets the value of the lowerLeftLat property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setLowerLeftLat(Float value) {
        this.lowerLeftLat = value;
    }

    /**
     * Gets the value of the lowerLeftLon property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getLowerLeftLon() {
        return lowerLeftLon;
    }

    /**
     * Sets the value of the lowerLeftLon property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setLowerLeftLon(Float value) {
        this.lowerLeftLon = value;
    }

    /**
     * Gets the value of the upperRightLat property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getUpperRightLat() {
        return upperRightLat;
    }

    /**
     * Sets the value of the upperRightLat property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setUpperRightLat(Float value) {
        this.upperRightLat = value;
    }

    /**
     * Gets the value of the upperRightLon property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getUpperRightLon() {
        return upperRightLon;
    }

    /**
     * Sets the value of the upperRightLon property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setUpperRightLon(Float value) {
        this.upperRightLon = value;
    }

    /**
     * Gets the value of the mapProjectionString property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMapProjectionString() {
        return mapProjectionString;
    }

    /**
     * Sets the value of the mapProjectionString property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMapProjectionString(String value) {
        this.mapProjectionString = value.trim();
    }

}