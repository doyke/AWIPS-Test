/**
* This software was developed and / or modified by Raytheon Company,
* pursuant to Contract DG133W-05-CQ-1067 with the US Government.
* 
* U.S. EXPORT CONTROLLED TECHNICAL DATA
* This software product contains export-restricted data whose
* export/transfer/disclosure is restricted by U.S. law. Dissemination
* to non-U.S. persons whether in the United States or abroad requires
* an export license or other authorization.
* 
* Contractor Name:        Raytheon Company
* Contractor Address:     6825 Pine Street, Suite 340
*                         Mail Stop B8
*                         Omaha, NE 68106
*                         402.291.0100
* 
* See the AWIPS II Master Rights File ("Master Rights File.pdf") for
* further licensing information.
**/
package com.raytheon.uf.common.dataplugin.shef.tables;
// default package
// Generated Oct 17, 2008 2:22:17 PM by Hibernate Tools 3.2.2.GA

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * Sshpconfig generated by hbm2java
 * 
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Oct 17, 2008                        Initial generation by hbm2java
 * Aug 19, 2011      10672     jkorman Move refactor to new project
 * Oct 07, 2013       2361     njensen Removed XML annotations
 * 
 * </pre>
 * 
 * @author jkorman
 * @version 1.1
 */
@Entity
@Table(name = "sshpconfig")
@com.raytheon.uf.common.serialization.annotations.DynamicSerialize
public class Sshpconfig extends com.raytheon.uf.common.dataplugin.persist.PersistableDataObject implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String lid;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String basinId;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Date postingtime;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String modelPref;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String autoProcess;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String sourcePref;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String useStaticEvap;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String useBlend;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String blendMethod;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private int blendHours;

    public Sshpconfig() {
    }

    public Sshpconfig(String lid, String basinId, Date postingtime,
            String modelPref, String autoProcess, String sourcePref,
            String useStaticEvap, String useBlend, String blendMethod,
            int blendHours) {
        this.lid = lid;
        this.basinId = basinId;
        this.postingtime = postingtime;
        this.modelPref = modelPref;
        this.autoProcess = autoProcess;
        this.sourcePref = sourcePref;
        this.useStaticEvap = useStaticEvap;
        this.useBlend = useBlend;
        this.blendMethod = blendMethod;
        this.blendHours = blendHours;
    }

    @Id
    @Column(name = "lid", unique = true, nullable = false, length = 8)
    public String getLid() {
        return this.lid;
    }

    public void setLid(String lid) {
        this.lid = lid;
    }

    @Column(name = "basin_id", nullable = false, length = 8)
    public String getBasinId() {
        return this.basinId;
    }

    public void setBasinId(String basinId) {
        this.basinId = basinId;
    }

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "postingtime", nullable = false, length = 29)
    public Date getPostingtime() {
        return this.postingtime;
    }

    public void setPostingtime(Date postingtime) {
        this.postingtime = postingtime;
    }

    @Column(name = "model_pref", nullable = false, length = 10)
    public String getModelPref() {
        return this.modelPref;
    }

    public void setModelPref(String modelPref) {
        this.modelPref = modelPref;
    }

    @Column(name = "auto_process", nullable = false, length = 1)
    public String getAutoProcess() {
        return this.autoProcess;
    }

    public void setAutoProcess(String autoProcess) {
        this.autoProcess = autoProcess;
    }

    @Column(name = "source_pref", nullable = false, length = 20)
    public String getSourcePref() {
        return this.sourcePref;
    }

    public void setSourcePref(String sourcePref) {
        this.sourcePref = sourcePref;
    }

    @Column(name = "use_static_evap", nullable = false, length = 1)
    public String getUseStaticEvap() {
        return this.useStaticEvap;
    }

    public void setUseStaticEvap(String useStaticEvap) {
        this.useStaticEvap = useStaticEvap;
    }

    @Column(name = "use_blend", nullable = false, length = 1)
    public String getUseBlend() {
        return this.useBlend;
    }

    public void setUseBlend(String useBlend) {
        this.useBlend = useBlend;
    }

    @Column(name = "blend_method", nullable = false, length = 10)
    public String getBlendMethod() {
        return this.blendMethod;
    }

    public void setBlendMethod(String blendMethod) {
        this.blendMethod = blendMethod;
    }

    @Column(name = "blend_hours", nullable = false)
    public int getBlendHours() {
        return this.blendHours;
    }

    public void setBlendHours(int blendHours) {
        this.blendHours = blendHours;
    }

}
