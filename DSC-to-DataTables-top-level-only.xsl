<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mdc="http://mdc"
    xmlns:ead="urn:isbn:1-931666-22-9" exclude-result-prefixes="xs math xlink ead mdc" version="2.0">

    <xsl:import href="EAD-combine-title-and-date.xsl"/>

    <xsl:output method="html" version="5.0" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:function name="mdc:container-to-number" as="xs:decimal">
        <xsl:param name="current-container" as="xs:string"/>
        <xsl:variable name="primary-container-number" select="replace($current-container, '\D', '')"/>
        <xsl:variable name="primary-container-modify">
            <xsl:choose>
                <xsl:when test="matches($current-container, '\D')">
                    <xsl:analyze-string select="$current-container" regex="(\D)(\s?)">
                        <xsl:matching-substring>
                            <xsl:value-of
                                select="number(string-to-codepoints(upper-case(regex-group(1))))"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="00"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of
            select="xs:decimal(concat($primary-container-number, '.', $primary-container-modify))"/>
    </xsl:function>

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
                    
                    table.dataTable tbody td.details{
                        padding-left:4em;
                    }</style>
                <script type="text/javascript" language="javascript" src="DataTables-1.10.0-beta.2/media/js/jquery.js"/>
                <script type="text/javascript" language="javascript" src="DataTables-1.10.0-beta.2/media/js/jquery.dataTables.js"/>
                <script type="text/javascript" language="javascript" src="DataTables-1.10.0-beta.2/examples/resources/syntax/shCore.js"/>
                <script type="text/javascript" language="javascript" src="DataTables-1.10.0-beta.2/examples/resources/demo.js"/>

                <script type="text/javascript" class="init">			
                    /* Formating function for row details */
                    function fnFormatDetails ( oTable, nTr )
                    {
                    var aData = oTable.fnGetData( nTr );
                    var sOut = '&lt;table>';
                    sOut += '&lt;tr>&lt;td>'+aData[3]+'&lt;/td>&lt;/tr>';
                        sOut += '&lt;/table>';
                    
                    return sOut;
                    }
                    
                    $(document).ready(function() {
                    /*
                    * Insert a 'details' column to the table
                    */
                    var nCloneTh = document.createElement( 'th' );
                    var nCloneTd = document.createElement( 'td' );
                    nCloneTd.setAttribute("class", "sorting_1");
                    nCloneTd.innerHTML = '&lt;img src="DataTables-1.10.0-beta.2/media/images/details_open.png">';

                        
                        $('#example thead tr').each( function () {
                        this.insertBefore( nCloneTh, this.childNodes[2] );
                        } );
                        
                        $('#example tbody tr').each( function () {
                        this.insertBefore(  nCloneTd.cloneNode( true ), this.childNodes[2] );
                        } );
                        
                        /*
                        * Initialse DataTables, with no sorting on the 'details' column
                        */
                        var oTable = $('#example').dataTable( {
                        "bPaginate": false,
                        "aoColumnDefs": [
                        { "bSortable": false, "aTargets": [ 0, 1 ] },
                        { "bSearchable": false, "aTargets": [ 0, 1, 3 ] },
                        { "bVisible": false, "aTargets": [ 3 ] },
                        ],
                        "aoColumns": [
                        { "sWidth": "4%" },
                        { "sWidth": "2%" },
                        { "sWidth": "94%" }],
                        "aaSorting": [[2, 'asc']]
                        });
                        
                        /* Add event listener for opening and closing details
                        * Note that the indicator for showing which row is open is not controlled by DataTables,
                        * rather it is done here
                        */
                        $('#example tbody td img').on('click', function () {
                        var nTr = this.parentNode.parentNode;
                        if ( this.src.match('details_close') )
                        {
                        /* This row is already open - close it */
                        this.src = "DataTables-1.10.0-beta.2/media/images/details_open.png";
                        oTable.fnClose( nTr );
                        }
                        else
                        {
                        /* Open this row */
                        this.src = "DataTables-1.10.0-beta.2/media/images/details_close.png";
                        oTable.fnOpen( nTr, fnFormatDetails(oTable, nTr), 'details' );
                        }
                        } );
                        } );
                                </script>
            </head>
            <body>
                <h1>
                    <xsl:apply-templates
                        select="/ead:ead/ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[not(@type)]"
                    />
                </h1>
                <br/>
                <!-- add more collection-level information here, whether from the archdesc/did or whether computed from the dsc-->
                <button type="button">Request Checked Boxes</button>
                <br/>
                <br/>
                <br/>
                <table id="example" class="display">
                    <thead>
                        <tr>
                            <th>Request</th>
                            <th>Container</th>
                            <th>Folder List</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each-group
                            select="descendant-or-self::*[ead:did/ead:container/@id]"
                            group-by="descendant-or-self::*/ead:did/ead:container[1]/text()/normalize-space()">
                            <xsl:for-each select="current-grouping-key()">
                                <xsl:call-template name="row-group"/>
                            </xsl:for-each>
                        </xsl:for-each-group>
                    </tbody>
                </table>
            </body>
        </html>
    </xsl:template>


    <xsl:template name="row-group">
        <tr>
            <!--Request-->
            <td class="center">
                <input type="checkbox"/>
            </td>
            <!--Container-->
            <td>
                <xsl:attribute name="data-sort">
                    <xsl:value-of select="mdc:container-to-number(current-grouping-key())"/>
                </xsl:attribute>
                <xsl:value-of
                    select="concat(current-group()[1]/ead:did/ead:container[1]/@type, ' ', current-grouping-key())"
                />
            </td>
            <!--Folders-->
            <td>
                <ul>
                    <xsl:apply-templates select="current-group()/ead:did/ead:unittitle" mode="list"/>
                </ul>
            </td>
        </tr>
    </xsl:template>


    <xsl:template match="ead:unittitle" mode="list">
           <xsl:call-template name="combine-that-title-and-date"/>
    </xsl:template>
   
   
    <xsl:template match="ead:emph[@render='italic']|ead:title[@render='italic']">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>

   

    <xsl:template match="ead:titleproper/ead:num"/>

</xsl:stylesheet>
