<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mdc="http://mdc"
    xmlns:ead="urn:isbn:1-931666-22-9" exclude-result-prefixes="xs math xlink ead mdc" version="2.0">

    <xsl:output method="html" version="5.0" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:function name="mdc:container-to-number" as="xs:decimal">
        <xsl:param name="current-container" as="node()*"/>
                
        <xsl:variable name="primary-container-number" select="replace($current-container, '\D', '')"/>
        
        <xsl:variable name="primary-container-modify">
            <xsl:choose>
                <xsl:when test="matches($current-container, '\D')">
                    <xsl:analyze-string select="$current-container" regex="(\D)(\s?)">
                        <xsl:matching-substring>
                            <xsl:value-of select="number(string-to-codepoints(upper-case(regex-group(1))))"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="00"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="id-attribue" select="$current-container/@id"/>
        
        <xsl:variable name="secondary-container-number">
            <xsl:choose>
                <xsl:when test="$current-container/following-sibling::ead:container[@parent eq $id-attribue][1]">
                    <xsl:value-of select="format-number(number(replace($current-container/following-sibling::ead:container[@parent eq $id-attribue][1], '\D', '')), '000000')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="000000"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
            
          <xsl:variable name="tertiary-container-number">
              <xsl:choose>
                  <xsl:when test="$current-container/following-sibling::ead:container[@parent eq $id-attribue][2]">
                      <xsl:value-of select="format-number(number(replace($current-container/following-sibling::ead:container[@parent eq $id-attribue][2], '\D', '')), '000000')"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="000000"/>
                  </xsl:otherwise>
              </xsl:choose>
          </xsl:variable>
        
        <xsl:value-of select="xs:decimal(concat($primary-container-number, '.', $primary-container-modify, $secondary-container-number, $tertiary-container-number))"/>
    </xsl:function>

    <xsl:variable name="quote">
        <xsl:text>&quot;</xsl:text>
    </xsl:variable>
    
    <xsl:variable name="apostrophe">
        <xsl:text>&apos;</xsl:text>
    </xsl:variable>

    
    


    <xsl:template match="ead:ead">
        <xsl:apply-templates select="ead:archdesc/ead:dsc"/>
    </xsl:template>

    <xsl:template match="ead:dsc">
        <html>
            <head>
                <meta charset="utf-8"/>

                <link rel="stylesheet" type="text/css"
                    href="DataTables-1.10.0-beta.2/media/css/jquery.dataTables.css"/>
                <link rel="stylesheet" type="text/css"
                    href="DataTables-1.10.0-beta.2/examples/resources/syntax/shCore.css"/>
                <link rel="stylesheet" type="text/css"
                    href="DataTables-1.10.0-beta.2/examples/resources/demo.css"/>
                <style type="text/css" class="init">
                    body{
                        padding:0 80px 80px 80px;
                    }
                    table,
                    thead,
                    tr,
                    td,
                    th{
                        text-align:left;
                    }
                .indent1 {padding-left:1em}
                .indent2 {padding-left:2em}
                .indent3 {padding-left:3em}
                .indent4 {padding-left:4em}
                .indent5 {padding-left:5em}
                .indent6 {padding-left:6em}
                .indent7 {padding-left:7em}
                .indent8 {padding-left:8em}
                .indent9 {padding-left:9em}
                .indent10 {padding-left:10em}
                .indent11 {padding-left:11em}
                .indent12 {padding-left:12em}
                </style>
                <script type="text/javascript" language="javascript" src="DataTables-1.10.0-beta.2/media/js/jquery.js"/>
                <script type="text/javascript" language="javascript" src="DataTables-1.10.0-beta.2/media/js/jquery.dataTables.js"/>
                <script type="text/javascript" language="javascript" src="DataTables-1.10.0-beta.2/examples/resources/syntax/shCore.js"/>
                <script type="text/javascript" language="javascript" src="DataTables-1.10.0-beta.2/examples/resources/demo.js"/>

                <script type="text/javascript" class="init">			
                    $(document).ready(function() {
                    var oTable = $('#example').DataTable({
                    "fnDrawCallback": function ( oSettings ) {
                    if ( oSettings.aiDisplay.length == 0 )
                    {
                    return;
                    }
                    
                    var nTrs = $('#example tbody tr');
                    var iColspan = nTrs[0].getElementsByTagName('td').length;
                    var sLastGroup = "";
                    for ( var i=0 ; i &lt; nTrs.length ; i++ )
                        {
                        var iDisplayIndex = oSettings._iDisplayStart + i;
                        var sGroup = oSettings.aoData[ oSettings.aiDisplay[iDisplayIndex] ]._aData[0];
                        if ( sGroup != sLastGroup )
                        {
                        var nGroup = document.createElement( 'tr' );
                        var nCell = document.createElement( 'td' );
                        var newCheckBox = document.createElement ( 'input' );
                        newCheckBox.type = 'checkbox';
                        nCell.colSpan = iColspan;
                        nCell.className = "group";
                        nCell.innerHTML = sGroup;
                        nCell.appendChild ( newCheckBox );
                        nGroup.appendChild ( nCell );
                        
                        
                        
                        nTrs[i].parentNode.insertBefore( nGroup, nTrs[i] );
                        sLastGroup = sGroup;
                        
                        }
                        }
                        },
                        "aoColumnDefs": [
                        { "bVisible": false, "aTargets": [ 0 ] },
                        { "bSortable": false, "aTargets": [ 1 ] },
                        { "bSearchable": false, "aTargets": [ 1, 2 ] }
                        ],
                        
                        "aaSorting": [[ 2, 'asc' ]],
                        "sDom": 'lfr&lt;"giveHeight"t>ip'
                        });
                        
                        
                        $('a.toggle-vis').on( 'click', function (e) {
                        e.preventDefault();
                        
                        // Get the column API object
                        var column = oTable.column( $(this).attr('data-column') );
                        
                        // Toggle the visibility
                        column.visible( ! column.visible() );
                        } );
                        
                        } );
                                </script>
            </head>
            <body>
                <h1>
                    <xsl:apply-templates select="/ead:ead/ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[not(@type)]"/>
                </h1>
                <br/>

                                
                <div>Toggle column:  <a class="toggle-vis" data-column="2">Container</a> -
                    <a class="toggle-vis" data-column="3">Title</a> - <a class="toggle-vis"
                    data-column="4">Contained In</a> - <a
                        class="toggle-vis" data-column="5">Date</a></div>

                <br/>

                <button type="button">Request Checked Boxes</button>

                <br/><br/><br/>

                <table id="example" class="display">
                    <thead>
                        <tr>
                            <th>Box</th>
                            <th>Request</th>
                            <th>Container</th>
                            <th>Title</th>
                            <th>Contained In</th>
                            <th>Date</th>
                            <!--
				<th>ID #</th>
				-->

                            <!--
                <th>Access Note</th>
	<th>Description</th>
		-->
                        </tr>
                    </thead>

                    <tfoot>
                        <tr>
                            <th>Box</th>
                            <th>Request</th>
                            <th>Container</th>
                            <th>Title</th>
                            <th>Contained In</th>
                            <th>Date</th>
                            <!--
				<th>ID #</th>
				-->
                            <!--
                <th>Access Note</th>
				<th>Description</th>
				-->
                        </tr>
                    </tfoot>

                    <tbody>
                        <xsl:apply-templates select="ead:c|ead:c01"/>
                    </tbody>
                </table>

            </body>
        </html>
    </xsl:template>

    <xsl:template
        match="ead:c|ead:c01|ead:c02|ead:c03|ead:c04|ead:c05|ead:c06|ead:c07|ead:c08|ead:c09|ead:c10|ead:c11|ead:c12">
        <xsl:apply-templates
            select="ead:did/ead:container[@id] | ead:c|ead:c02|ead:c03|ead:c04|ead:c05|ead:c06|ead:c07|ead:c08|ead:c09|ead:c10|ead:c11|ead:c12"
        />
    </xsl:template>

    <!--creates each TR-->
    <xsl:template match="ead:container[@id]">
        
        <tr>
            <!-- hidden column, for row-grouping -->
            <td>
                <xsl:value-of select="concat(lower-case(@type), ' ', .)"/>
            </td>       
            <!--Request-->
            <td>
                <input type="checkbox"/>
            </td>
            <!--Container-->
            <td>                
                <xsl:attribute name="data-sort">
                    <xsl:value-of select="mdc:container-to-number(.)"/>
                </xsl:attribute>
                <xsl:value-of select="concat(lower-case(@type), ' ', .)"/>
                <xsl:apply-templates
                    select="following-sibling::ead:container[@parent eq current()/@id]"/>
            </td>
            <!--Title-->
            <td>
                <xsl:choose>
                    <xsl:when test="../ead:unittitle/normalize-space()">
                        <xsl:attribute name="data-sort">
                            <xsl:value-of select="replace(../ead:unittitle, '$quote|$apostrophe|&#33;|&#34;|&#35;|&#37;', '')"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="../ead:unittitle"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="data-sort">
                            <xsl:value-of select="replace(ancestor::*[ead:did/ead:unittitle[normalize-space()]][1]/ead:did/ead:unittitle, 
                                '$quote|$apostrophe|&#33;|&#34;|&#35;|&#37;',
                                '')"/>
                        </xsl:attribute>
                        <xsl:apply-templates
                            select="ancestor::*[ead:did/ead:unittitle[normalize-space()]][1]/ead:did/ead:unittitle"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!--Contained In-->
            <td>
                <xsl:apply-templates select="../../ancestor::ead:*[ead:did][not(ead:dsc)]/ead:did/ead:unittitle" mode="contained-in-column"/>
            </td>
            <!--Date-->
            <td>
                <xsl:apply-templates select="../ead:unitdate"/>
            </td>

        </tr>
    </xsl:template>

    <xsl:template match="ead:container[@parent]">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="concat(lower-case(@type), ' ', .)"/>
    </xsl:template>

    <xsl:template match="ead:unittitle" mode="contained-in-column">
        <div>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('indent', count(ancestor::*) - 5)"/>
            </xsl:attribute>
            <xsl:text>- </xsl:text>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="ead:emph[@render='italic']|ead:title[@render='italic']">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    
    <xsl:template match="ead:titleproper/ead:num"/>
    
</xsl:stylesheet>
