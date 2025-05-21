<!------------------------------------------------------------------------------------------------------
	//           NEWGEN SOFTWARE TECHNOLOGIES LIMITED
	
	//Group						 : Application –Projects
	//Product / Project			 : RAKBank 
	//Module                     : Request-Initiation 
	//File Name					 : TL.jsp
	//Author                     : Ankit	
	// Date written (DD/MM/YYYY) : 07-Dec-2015
	//Description                : Initial Header fixed form for CIF Updates
	//---------------------------------------------------------------------------------------------------->
<%@ include file="../TL_Specific/Log.process"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.net.*"%>
<%@ page import="com.newgen.wfdesktop.xmlapi.*" %>
<%@ page import="com.newgen.custom.*" %>
<%@ page import="com.newgen.wfdesktop.util.*" %>
<%@ page import="java.math.*"%>
<%@ page import="com.newgen.wfdesktop.exception.*" %>
<%@ page import="com.newgen.mvcbeans.model.*,com.newgen.mvcbeans.controller.workdesk.*"%>
<%@ page import="com.newgen.omni.wf.util.app.*"%>
<%@ page import="com.newgen.omni.wf.util.excp.*"%>
<%@ page import="com.newgen.omni.wf.util.app.NGEjbClient"%>
<%@ page import="com.newgen.omni.wf.util.excp.NGException"%>
<%@ page import="org.owasp.esapi.ESAPI"%>
<%@ page import="org.owasp.esapi.codecs.OracleCodec"%>
<%@ page import="org.owasp.esapi.User" %>

<%@ page import="com.newgen.mvcbeans.model.wfobjects.WFDynamicConstant ,com.newgen.mvcbeans.model.*,com.newgen.mvcbeans.controller.workdesk.*,javax.faces.context.FacesContext,com.newgen.mvcbeans.controller.workdesk.*,java.util.*;"%>
<!-- esapi4js i18n resources -->
<script type="text/javascript" language="JavaScript" src="${pageContext.request.contextPath}/CustomForms/esapi4js/resources/i18n/ESAPI_Standard_en_US.properties.js"></script>
<!-- esapi4js configuration -->
<script type="text/javascript" language="JavaScript" src="${pageContext.request.contextPath}/CustomForms/esapi4js/esapi-compressed.js"></script>
<script type="text/javascript" language="JavaScript" src="${pageContext.request.contextPath}/CustomForms/esapi4js/resources/Base.esapi.properties.js"></script>
<!-- esapi4js core -->
<jsp:useBean id="wDSession" class="com.newgen.wfdesktop.session.WDSession" scope="session"/>
<script src="jquery.min.js"></script>
<script src="bootstrap.min.js"></script>
<script src="jquery-ui.js"></script>
<%!
	public String getTagValues(String sXML, String sTagName) {
	       String sTagValues = "";
	       String sStartTag = "<" + sTagName + ">";
	       String sEndTag = "</" + sTagName + ">";
	       String tempXML = sXML;
	       try {
	           for (int i = 0; i < sXML.split(sEndTag).length - 1; i++) {
	               if (tempXML.indexOf(sStartTag) != -1) {
	                   sTagValues += tempXML.substring(tempXML.indexOf(sStartTag)
	                           + sStartTag.length(), tempXML.indexOf(sEndTag));
	                   tempXML = tempXML.substring(tempXML.indexOf(sEndTag)
	                           + sEndTag.length(), tempXML.length());
	               }
	               if (tempXML.indexOf(sStartTag) != -1) {
	                   sTagValues += ",";
	               }
	           }
	       } catch (Exception e) {
	           System.out.println("Exception: " + e.getMessage());
	       }
	       return sTagValues;
	   }
	%>

<%! 
	public String getTagValuesforIndustry(String sXML, String sTagName) {
	       String sTagValues = "";
	       String sStartTag = "<" + sTagName + ">";
	       String sEndTag = "</" + sTagName + ">";
	       String tempXML = sXML;
	       try {
	           for (int i = 0; i < sXML.split(sEndTag).length - 1; i++) {
	               if (tempXML.indexOf(sStartTag) != -1) {
	                   sTagValues += tempXML.substring(tempXML.indexOf(sStartTag)
	                           + sStartTag.length(), tempXML.indexOf(sEndTag));
	                   tempXML = tempXML.substring(tempXML.indexOf(sEndTag)
	                           + sEndTag.length(), tempXML.length());
	               }
	               if (tempXML.indexOf(sStartTag) != -1) {
	                   sTagValues += "#";
	               }
	           }
	       } catch (Exception e) {
	           System.out.println("Exception: " + e.getMessage());
	       }
	       return sTagValues;
	   }
	%>
<%! 
public String getdescription(String tableName, String value, String cabinetName, String sessionId, String serverIP, String serverPort, String appServerType) {
    String desc = "";
    try {
        if (tableName == null || value == null) return desc;

        String query = "SELECT TOP 1 SEGMENT_DESC FROM " + tableName + " WITH(NOLOCK) WHERE SEGMENT_CODE='" + value + "' AND ISACTIVE='Y'";
        String inputData = "<?xml version='1.0'?><APSelectWithColumnNames_Input>" +
                           "<Option>APSelectWithColumnNames</Option>" +
                           "<Query>" + query + "</Query>" +
                           "<EngineName>" + cabinetName + "</EngineName>" +
                           "<SessionId>" + sessionId + "</SessionId>" +
                           "</APSelectWithColumnNames_Input>";

        String outputData = NGEjbClient.getSharedInstance().makeCall(
            serverIP,
            serverPort,
            appServerType,
            inputData
        );

        XMLParser xmlParserData = new XMLParser();
        xmlParserData.setInputXML(outputData);
        String maincode = xmlParserData.getValueOf("MainCode");

        if ("0".equals(maincode) && outputData.contains("SEGMENT_DESC")) {
            desc = getTagValues(outputData, "SEGMENT_DESC");
        }

    } catch (Exception e) {
        // Logging must be handled outside or passed in
    }
    return desc;
	}
%>

	
<%
	String DecisionCombo[]=null;
	String DecisionComboValues[]=null;
	String QueryValues[]=null;
	String documentValues[]=null;
	String selectedDocumentValues[]=null;
	String rCIFIDS[]=null;
	String fName[]=null;
	String lName[]=null;
	String relationTypes[]=null;
	String Query="";
	String inputData="";
	String outputData="";
	String maincode="";
	String FlagValue="";
	XMLParser xmlParserData=null;
	XMLParser objXmlParser=null;
	String subXML="";
	String channel="";
	
	String selectedDocsList[];
	
			String input1 = ESAPI.encoder().encodeForHTML( ESAPI.validator().getValidSafeHTML("htmlInput", request.getParameter("ProcessInstanceId"), 1000, true) );
			String ProcessInstanceId_Esapi = ESAPI.encoder().encodeForSQL(new OracleCodec(), input1!=null?input1:"");
			WriteLog("ProcessInstanceId_Esapi Request.getparameter---> "+request.getParameter("ProcessInstanceId"));
			WriteLog("ProcessInstanceId Esapi---> "+ProcessInstanceId_Esapi);
			
			String input2 = ESAPI.encoder().encodeForHTML( ESAPI.validator().getValidSafeHTML("htmlInput", request.getParameter("WorkitemId"), 1000, true) );
			String WorkitemId_Esapi = ESAPI.encoder().encodeForSQL(new OracleCodec(), input2!=null?input2:"");
			WriteLog("WorkitemId Request.getparameter---> "+request.getParameter("WorkitemId"));
			WriteLog("WorkitemId Esapi---> "+WorkitemId_Esapi);
			
			String input3 = ESAPI.encoder().encodeForHTML( ESAPI.validator().getValidSafeHTML("htmlInput", request.getParameter("IsDoneClicked"), 1000, true) );
			String IsDoneClicked_Esapi = ESAPI.encoder().encodeForSQL(new OracleCodec(), input3!=null?input3:"");
			WriteLog("IsDoneClicked Request.getparameter---> "+request.getParameter("IsDoneClicked"));
			WriteLog("IsDoneClicked Esapi---> "+IsDoneClicked_Esapi);
			
			String archivalModeFlag = ESAPI.encoder().encodeForHTML( ESAPI.validator().getValidSafeHTML("htmlInput", request.getParameter("ArchivalMode"), 1000, true) );
			String archivalModeFlag_Esapi = ESAPI.encoder().encodeForSQL(new OracleCodec(), archivalModeFlag!=null?archivalModeFlag:"");
			WriteLog("archivalModeFlag ---> "+request.getParameter("ArchivalMode"));
			WriteLog("archivalModeFlag_Esapi Esapi---> "+archivalModeFlag_Esapi);
			
			String ArchivalCabinet = ESAPI.encoder().encodeForHTML( ESAPI.validator().getValidSafeHTML("htmlInput", request.getParameter("ArchivalCabinet"), 1000, true) );
			String archivalCabinet_Esapi = ESAPI.encoder().encodeForSQL(new OracleCodec(), ArchivalCabinet!=null?ArchivalCabinet:"");
			WriteLog("ArchivalCabinet ---> "+request.getParameter("ArchivalCabinet"));
			WriteLog("archivalCabinet_Esapi Esapi---> "+archivalCabinet_Esapi);
			
			/*String archivalModeFlag = request.getParameter("ArchivalMode");
			WriteLog("archivalModeFlag :"+ archivalModeFlag);
			String ArchivalCabinet = request.getParameter("ArchivalCabinet");
			WriteLog("ArchivalCabinet :"+ ArchivalCabinet);  */
	
    String pid = ProcessInstanceId_Esapi;
	String wid = WorkitemId_Esapi;
	//String pid=request.getParameter("wdesk:pid");
	WriteLog("PID:---"+pid);
	//String wid=request.getParameter("wdesk:wid");
	WriteLog("WID:---"+wid);

    
     WDWorkitems wDWorkitems = (WDWorkitems) session.getAttribute("wDWorkitems");
    LinkedHashMap workitemMap = (LinkedHashMap) wDWorkitems.getWorkItems();
	 WorkdeskModel wdmodel = (WorkdeskModel)workitemMap.get(pid+"_"+wid);//currentworkdesk
	LinkedHashMap attributeMap=wdmodel.getAttributeMap();

	/*LinkedHashMap workitemMap=(LinkedHashMap)FacesContext.getCurrentInstance().getApplication().createValueBinding("#{workitems.workItems}").getValue(FacesContext.getCurrentInstance());
	WorkdeskModel wdmodel = (WorkdeskModel)workitemMap.get(pid+"_"+wid);//currentworkdesk
	LinkedHashMap attributeMap=wdmodel.getAttributeMap();
	WriteLog("attributeMap"+attributeMap);*/
	
	// Sample Code to Interate through Dynamic Constants and getting these values
	LinkedHashMap dynConstMap=wdmodel.getDynamicConstantMap();
			try{
		Set keySet = dynConstMap.keySet();
		Iterator<String> iterator = keySet.iterator();
		while(iterator.hasNext())
		{
			// Getting Dynamic Constant name
			String key = iterator.next();
			// Getting Dynamic Constant Value by its Name
			WFDynamicConstant value = (WFDynamicConstant)dynConstMap.get(key);
		}
	}catch(Exception ex)
	{
		//Do Nothing
	}
	String WSNAME  = wdmodel.getWorkitem().getActivityName();
	String IsDoneClicked=IsDoneClicked_Esapi;  
	WriteLog("WSNAME"+WSNAME+"doneclick"+IsDoneClicked);
	String WINAME = wdmodel.getWorkitem().getProcessInstanceId();
	int row=0;
	String selectedDocs = "";
	try{
		selectedDocs = ((WorkdeskAttribute)attributeMap.get("Supporting_Docs")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Supporting_Docs")).getValue();
	
		WriteLog("selectedDocs "+selectedDocs);
		
		if(selectedDocs!=null && selectedDocs!="")	
			selectedDocumentValues=selectedDocs.split("-");
	}catch(Exception e){}		
	
	//String map = ((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue();
	
	//WriteLog("==================map====================="+map);
	
	String readOnlyFlag="";
	try{
		readOnlyFlag = wdmodel.getViewMode();//get ReadOnly or not
		
	}catch(Exception e){}
	String strHideReadOnly="";
	String strDisableReadOnly="";
	WriteLog("readOnlyFlag:");
	WriteLog(readOnlyFlag);
	if("R".equalsIgnoreCase(readOnlyFlag))
	{
		strHideReadOnly="style='display:none'";
		strDisableReadOnly="disabled";
	}
	
	if(!WSNAME.equalsIgnoreCase("CSO"))
	{
		
		Query="SELECT COMBOID,VALUE FROM USR_0_TL_COMBOS with(nolock) WHERE Ws_Name='"+WSNAME+"' AND IsActive='Y' ORDER BY COMBOID ASC";
		inputData = "<?xml version='1.0'?><APSelectWithColumnNames_Input><Option>APSelectWithColumnNames</Option><Query>" + Query + "</Query><EngineName>" + wDSession.getM_objCabinetInfo().getM_strCabinetName()+ "</EngineName><SessionId>" + wDSession.getM_objUserInfo().getM_strSessionId() + "</SessionId></APSelectWithColumnNames_Input>";
		outputData = NGEjbClient.getSharedInstance().makeCall(wDSession.getM_objCabinetInfo().getM_strServerIP(), wDSession.getM_objCabinetInfo().getM_strServerPort(), wDSession.getM_objCabinetInfo().getM_strAppServerType(), inputData);
	
		xmlParserData=new XMLParser();
		xmlParserData.setInputXML((outputData));
		maincode = xmlParserData.getValueOf("MainCode");
		if(maincode.equals("0"))
		{
			DecisionCombo =getTagValues(outputData, "COMBOID").split(",");
			DecisionComboValues =getTagValues(outputData, "VALUE").split(",");
		}
		if("R".equalsIgnoreCase(readOnlyFlag))
			Query="SELECT DOC_Name FROM USR_0_TL_POSSIBLE_DOC with(nolock) WHERE Ws_Name='Read Only'";
		else
	
			Query="SELECT DOC_Name FROM USR_0_TL_POSSIBLE_DOC with(nolock) WHERE Ws_Name='"+WSNAME+"'";
			inputData = "<?xml version='1.0'?><APSelectWithColumnNames_Input><Option>APSelectWithColumnNames</Option><Query>" + Query + "</Query><EngineName>" +  wDSession.getM_objCabinetInfo().getM_strCabinetName() + "</EngineName><SessionId>" + wDSession.getM_objUserInfo().getM_strSessionId()+ "</SessionId></APSelectWithColumnNames_Input>";
		WriteLog("inputData: "+inputData);
	//	outputData = WFCallBroker.execute(inputData, wfsession.getJtsIp(), wfsession.getJtsPort(), 1);
		outputData = NGEjbClient.getSharedInstance().makeCall(wDSession.getM_objCabinetInfo().getM_strServerIP(), wDSession.getM_objCabinetInfo().getM_strServerPort(), wDSession.getM_objCabinetInfo().getM_strAppServerType(), inputData);


		WriteLog("outputData: "+outputData);
		
		xmlParserData.setInputXML((outputData));
		maincode = xmlParserData.getValueOf("MainCode");
		
		if(maincode.equals("0"))
		{
			if(outputData.contains("DOC_Name"))
			{
				documentValues = getTagValues(outputData, "DOC_Name").split(",");
				WriteLog("outputData2");
			}
		}
      
		
	}
	
	%>
<%
	StringBuilder returnValues = new StringBuilder();
	try {
		String query1 = "SELECT SEGMENT_CODE, SEGMENT_DESC FROM USR_0_TL_INDUSTRYSEGMENT_MASTER WITH(NOLOCK)";
		inputData = "<?xml version='1.0'?><APSelectWithColumnNames_Input>" +
						   "<Option>APSelectWithColumnNames</Option>" +
						   "<Query>" + query1 + "</Query>" +
						   "<EngineName>" + wDSession.getM_objCabinetInfo().getM_strCabinetName() + "</EngineName>" +
						   "<SessionId>" + wDSession.getM_objUserInfo().getM_strSessionId() + "</SessionId>" +
						   "</APSelectWithColumnNames_Input>";
		outputData = NGEjbClient.getSharedInstance().makeCall(wDSession.getM_objCabinetInfo().getM_strServerIP(), wDSession.getM_objCabinetInfo().getM_strServerPort(), wDSession.getM_objCabinetInfo().getM_strAppServerType(), inputData);
		xmlParserData = new XMLParser();
		xmlParserData.setInputXML(outputData);
		maincode = xmlParserData.getValueOf("MainCode");
		if ("0".equals(maincode) && outputData.contains("SEGMENT_CODE")) {
			String segmentCodesStr = getTagValues(outputData, "SEGMENT_CODE");
			String segmentDescsStr = getTagValuesforIndustry(outputData, "SEGMENT_DESC");
			String[] segmentCodes = segmentCodesStr.split(",");
			String[] segmentDescs = segmentDescsStr.split("#");
			for (int i = 0; i < segmentCodes.length; i++) {
				returnValues.append(segmentCodes[i].trim()).append("|").append(segmentDescs[i].trim()).append("~");
			}
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
	String returnValuesStr = returnValues.toString();
%>

<%
	StringBuilder returnValues2 = new StringBuilder();
	try {
		String query2 = "SELECT SEGMENT_CODE, SEGMENT_DESC FROM USR_0_TL_INDUSTRYSUBSEGMENT_MASTER WITH(NOLOCK) ";
		inputData = "<?xml version='1.0'?><APSelectWithColumnNames_Input>" +
						   "<Option>APSelectWithColumnNames</Option>" +
						   "<Query>" + query2 + "</Query>" +
						   "<EngineName>" + wDSession.getM_objCabinetInfo().getM_strCabinetName() + "</EngineName>" +
						   "<SessionId>" + wDSession.getM_objUserInfo().getM_strSessionId() + "</SessionId>" +
						   "</APSelectWithColumnNames_Input>";
		outputData = NGEjbClient.getSharedInstance().makeCall(wDSession.getM_objCabinetInfo().getM_strServerIP(), wDSession.getM_objCabinetInfo().getM_strServerPort(), wDSession.getM_objCabinetInfo().getM_strAppServerType(), inputData);
		xmlParserData = new XMLParser();
		xmlParserData.setInputXML(outputData);
		maincode = xmlParserData.getValueOf("MainCode");
		if ("0".equals(maincode) && outputData.contains("SEGMENT_CODE")) {
			String subsegmentCodesStr = getTagValues(outputData, "SEGMENT_CODE");
			String subsegmentDescsStr = getTagValuesforIndustry(outputData, "SEGMENT_DESC");
			String[] subsegmentCodes = subsegmentCodesStr.split(",");
			String[] subsegmentDescs = subsegmentDescsStr.split("#");
			for (int i = 0; i < subsegmentCodes.length; i++) {
				returnValues2.append(subsegmentCodes[i].trim()).append("|").append(subsegmentDescs[i].trim()).append("~");
			}
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
	String returnValuesStr2 = returnValues2.toString();
%>

<%
	StringBuilder returnValues3 = new StringBuilder();
	try {
		String query3 = "SELECT LEGAL_ENTITY_CODE, LEGAL_ENTITY_DESC FROM USR_0_TL_LEGAL_ENTITY_MASTER WITH(NOLOCK)";
		inputData = "<?xml version='1.0'?><APSelectWithColumnNames_Input>" +
						   "<Option>APSelectWithColumnNames</Option>" +
						   "<Query>" + query3 + "</Query>" +
						   "<EngineName>" + wDSession.getM_objCabinetInfo().getM_strCabinetName() + "</EngineName>" +
						   "<SessionId>" + wDSession.getM_objUserInfo().getM_strSessionId() + "</SessionId>" +
						   "</APSelectWithColumnNames_Input>";
		outputData = NGEjbClient.getSharedInstance().makeCall(wDSession.getM_objCabinetInfo().getM_strServerIP(), wDSession.getM_objCabinetInfo().getM_strServerPort(), wDSession.getM_objCabinetInfo().getM_strAppServerType(), inputData);
		xmlParserData = new XMLParser();
		xmlParserData.setInputXML(outputData);
		maincode = xmlParserData.getValueOf("MainCode");
		if ("0".equals(maincode) && outputData.contains("LEGAL_ENTITY_CODE")) {
			String legalentityCodesStr = getTagValues(outputData, "LEGAL_ENTITY_CODE");
			String legalentityDescsStr = getTagValues(outputData, "LEGAL_ENTITY_DESC");
			String[] legalentityCodes = legalentityCodesStr.split(",");
			String[] legalentityDescs = legalentityDescsStr.split(",");
			for (int i = 0; i < legalentityCodes.length; i++) {
				returnValues3.append(legalentityCodes[i].trim()).append("|").append(legalentityDescs[i].trim()).append("~");
			}
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
	String returnValuesStr3 = returnValues3.toString();
%>

<HTML>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
		<link rel="stylesheet" href="bootstrap.min.css">
		<link rel="stylesheet" href="jquery-ui.css">
		<style>		
			td {
				background-color : #FEFAEF;
				padding-left:5px;
				padding-right:5px;
				padding-top:2px;
				padding-bottom:2px;
			}
			th{
				background-color: #980033;
				color:white;
				padding-left:5px;
				padding-right:5px;
				padding-top:2px;
				padding-bottom:2px;
			}
			.accordion-heading {			
				padding:2px;
			}
			.accordion-heading {
				background-color: #980033;
				border : 1px solid gray;
			}
			.demographicSelect {
				width:53.5%;
			}
			.headerwidth{
				width:21%;
			}
			.custCheck {
				width:53.5%;
			}
			.multiSel {
				width:100%;
			}
			.decGrid {
				width:53.5%;
			} 
			.decDrop {
				width:25%;
			}
			.accDetailsSel {
				width:53.5%;
			}
			.fatcaSel {
				width:53.5%;
			}
			.kycSel {
				width:53.5%;
			}
			.contactSel {
				width:70%;
			}
			.panel-title > .small, .panel-title > .small > a, .panel-title > a, .panel-title > small, .panel-title > small > a {
				color: white;
			}
			.widthSel {
				width:21%;
			}
			.dropdown
			{
				width:139px;
			}
			.widthSelLabel {
				width:29%;
			}
			.dropwidth {
				width:60.5%;
			}
			textarea { white-space: pre-wrap; }
			a{
				color: white;
				text-decoration: none;
			}
		</style>
		<title>Trade License</title>
		<style>
			@import url("/webdesktop/webtop/en_us/css/docstyle.css");
		</style>
		<script src="/webdesktop/CustomForms/TL_Specific/Validation_TL.js"></script>
		<script src="moment.js"></script>
		<script language="JavaScript">
			document.onkeydown = mykeyhandler;
			function mykeyhandler() {
				var elementType=window.event.srcElement.type;
				var eventKeyCode=window.event.keyCode;
				var isAltKey=window.event.altKey;
				if(eventKeyCode==83 && isAltKey){
					window.parent.workdeskOperations('S');//Save Workitem
				}
				else if(eventKeyCode==73 && isAltKey){
					window.parent.workdeskOperations('I');//Introduce Workitem
				}
				else if (eventKeyCode == 116) {
					window.event.keyCode = 0;
					return false;
				}
				else if (eventKeyCode == 8 && elementType!='text' && elementType!='textarea' && elementType!='submit' && elementType!='password' ) 				  {
					window.event.keyCode = 0;
					return false;
				}
			}
			
			$(document).ready(function(){
				$("input:text,select,textarea").wrap("<div class='tooltip-wrapper'></div>");
				$( "div.tooltip-wrapper").mouseover(function() {					
						$(this).attr('title', $(this).children().val());
					});			
			});
			
			function HistoryCaller(){
				var WINAME=document.getElementById("temp_wi_name").value;
				var ArchivalMode=window.parent.ArchivalMode;
				
				//var openingModalWindow=window.showModalDialog("../TL_Specific/history.jsp?WINAME="+WINAME,"", "dialogWidth:60; dialogHeight:400px; center:yes;edge:raised; help:no; resizable:no; scroll:yes;scrollbar:yes; status:no; statusbar:no; toolbar:no; menubar:no; addressbar:no; titlebar:no;");
				var openingModalWindow = "";
				//added below to handle window.open/window.showModalDialog according to type of browser starts here.
				/***********************************************************/
				var windowParams="height=600,width=650,toolbar=no,directories=no,status=no,center=yes,scrollbars=no,resizable=no,modal=yes,addressbar=no,menubar=no";
				if (window.showModalDialog){
					window.showModalDialog("../TL_Specific/history.jsp?WINAME="+WINAME+"&ArchivalMode="+ArchivalMode,"", "dialogWidth:60; dialogHeight:400px; center:yes;edge:raised; help:no; resizable:no; scroll:yes;scrollbar:yes; status:no; statusbar:no; toolbar:no; menubar:no; addressbar:no; titlebar:no;");
				} else {
					//window.open("../TL_Specific/history.jsp?WINAME="+WINAME,"",windowParams);
					window.open("../TL_Specific/history.jsp?WINAME="+WINAME+"&ArchivalMode="+ArchivalMode,"",windowParams);
				}
				/************************************************************/
				//added below to handle window.open/window.showModalDialog according to type of browser  ends here.
			}
			
			function changeVal(dropdown,WSNAME)
			{		

				if(dropdown.id=='DecisionDropDown')
				{						
				
					document.getElementById("wdesk:Decision").value = dropdown.value;	
				
					var isblacklist = document.getElementById("wdesk:isblacklist").value ;
					//Change done by deepak to remove return condition 01june2016  
					/*else
					if(isblacklist == "Y")
					{
					
						// if(dropdown.value == "Reject TL")
						if(dropdown.value == "Front Office Reject")
						{
							document.getElementById("rejectreason").selectedIndex = "2";
						}
						
						{
							//alert("Customer is blacklisted, You can only select Front Office Reject Decision");
							return;
						}
					}
					*/			
					if(dropdown.value=="Approved with profile change" && (document.getElementById("wdesk:Supporting_Docs").value=='' || document.getElementById("wdesk:Supporting_Docs").value==null)) {
						alert("You can select the documents, required for Profile change.");
					}
					if(dropdown.value=='Approved with profile change'){
					//alert("Decision ::::::::: " + Decision);
						document.getElementById("wdesk:MemoPad").value = 'Renewed TL updated with Profile Change noted. Supporting documents pending.';
						document.getElementById("MemoPads").value = 'Renewed TL updated with Profile Change noted. Supporting documents pending';
					}
					else
					{
						document.getElementById("wdesk:MemoPad").value = '';
						document.getElementById("MemoPads").value = '';
					}
					
					// if(dropdown.value=="Reject TL") 
					if(dropdown.value=="Front Office Reject" || dropdown.value=="Reject To Maker") 
					{
						document.getElementById("rejectreason").disabled = false;	
						document.getElementById("rejectreason").value = "--Select--";											
						document.getElementById("wdesk:RejectReason").value = "";
					}	
					else
					{
						document.getElementById("rejectreason").disabled = false;
						document.getElementById("wdesk:RejectReason").value = "";
						document.getElementById("rejectreason").value = "--Select--";		
						document.getElementById("rejectreason").disabled = true;					
					}
					if (dropdown.value=="Approved with profile change")
					{
						document.getElementById("rejectreason").disabled = false;	
					}
					
				
									
				}
				else if(dropdown.id=='rejectreason'){
					document.getElementById("wdesk:RejectReason").value = dropdown.value;	
				}
				
				else if(dropdown.id=='Emirates'){
					document.getElementById("wdesk:Emirates").value = dropdown.value;	
				}
			}
			
			function loadDropDownValues()
			{
				
				var dropDownArray=['Emirates'];
				var textBoxArray=['wdesk:Emirates'];
				for(var i=0;i<dropDownArray.length;i++)
				{
					var textBoxValue=document.getElementById(textBoxArray[i]).value;
					if(textBoxValue!='')
						document.getElementById(dropDownArray[i]).value=textBoxValue;
				}
		
			}
			
			function showDivForRadio(Object) {
			
			
				div = document.getElementById('divCheckbox2');
				div.style.display = "block";
			
			}
			//Add 1 Year to the existing. include moment.js
			function setDate()
			 {
				var old_date = document.getElementById('wdesk:Exis_Expiry_Date').value;
				if (trim(old_date) == 'null')
				{
					document.getElementById('wdesk:Exis_Expiry_Date').value='';
					old_date='';
				}
				if (trim(old_date) != '')
				{
					 var arrolddate = old_date.split("/");
					 
					 var olddate = new Date(arrolddate[2],arrolddate[1]-1, arrolddate[0]);
					 olddate.setMonth(olddate.getMonth()+12);
					 
					 var newDay=olddate.getDate()+"";
					 var newMonth=(olddate.getMonth()+1)+"";
					 if(newDay.length==1)
						 newDay = '0'+olddate.getDate();
					 if(newMonth.length==1)
						 newMonth = '0'+(olddate.getMonth()+1);
					 
					if(isNaN(newDay))
						 document.getElementById('wdesk:New_Expiry_Date').value="";
					else	 
						document.getElementById('wdesk:New_Expiry_Date').value = newDay+'/'+(newMonth)+'/'+olddate.getFullYear();
				}
			 }
			 
			function showDivForGrid(Object) {			
				div = document.getElementById('divCheckbox2');
				div.style.display = "block";
				//alert(Object.value);
				document.getElementById("wdesk:CIF_Num").value = Object.value;
				GetSearchDetails();
				//alert(document.getElementById("wdesk:New_Expiry_Date").value);
				if(!(document.getElementById("wdesk:New_Expiry_Date").value !="" && document.getElementById("wdesk:New_Expiry_Date").value !=" " &&document.getElementById("wdesk:New_Expiry_Date").value !=null))
				{
					//alert("inside2");
					var oldDate = document.getElementById('wdesk:Exis_Expiry_Date').value;
					if (trim(oldDate) == 'null')
					{
						document.getElementById('wdesk:Exis_Expiry_Date').value='';
						oldDate='';
					}
					if (trim(oldDate) != '')
					{
						var arrOldDate = oldDate.split("/");
						//alert(arrOldDate[2]);
						var newDate = new Date(arrOldDate[2],arrOldDate[1]-1,arrOldDate[0]);
						newDate.setMonth(newDate.getMonth()+12);
						//alert(newDate);
						var newDay=newDate.getDate()+"";
						var newMonth=(newDate.getMonth()+1)+"";
						//alert("length"+newDay.length );
						if(newDay.length==1)
							newDay = '0'+newDate.getDate();
						if(newMonth.length==1)
							newMonth = '0'+(newDate.getMonth()+1);
						document.getElementById('wdesk:New_Expiry_Date').value = newDay+'/'+(newMonth)+'/'+newDate.getFullYear();
						
						//setDate();
					}
				}
			
			}
			
			function initForm(WSNAME,sMode) {
			
				$('.accordion-body').collapse('show');
				var wi_name = '<%=WINAME%>';
				//alert(wi_name);
				//div = document.getElementById('divCheckbox2');
				//div.style.display = "block";
				//alert($("#selectedList").innerWidth()); 
				//alert(document.getElementById("selectedList").offsetWidth);
				//document.getElementById("selectedList").style.Width = "200px";
				//document.getElementById("documentList").style.Width = "200px";
				
				if($("#selectedList").innerWidth() < 0)
				{
					document.getElementById("selectedList").style.Width = "220px";
				}
				if($("#documentList").innerWidth() < 0)
				{
					document.getElementById("selectedList").style.Width = "220px";
				}
				if (sMode=="R")
				{
					showDivForRadio();
					onLoadShowShareHoldersDetails();
					showSelectedDocumnets();
					CheckEnableDisable();
					return;
				}
				if(WSNAME=="OPS_Maker"){
					//CR change on 15112016
					document.getElementById("wdesk:Decision").value = "Activity Completed";
					
					if(!(document.getElementById("wdesk:New_Expiry_Date").value !="" && document.getElementById("wdesk:New_Expiry_Date").value !=" " &&document.getElementById("wdesk:New_Expiry_Date").value !=null))
					{
						//alert("inside1");
						setDate();
					}
					
					//commented by Aishwarya for sol_id change
					/*var solId=document.getElementById('wdesk:sol_id').value;
					if(solId==null||solId=="")
						ajaxRequest(WSNAME,'getSolId');*/
					
					var element = document.getElementById("TL_mainGrid");
					
					if(typeof(element) != 'undefined' && element != null)
					{
						var row = document.getElementById("TL_mainGrid").rows.length;
						if(row >2)
						{
							document.getElementById("row1_individual").checked = false;
							var cif_value = document.getElementById("wdesk:CIF_Num").value;
							var chks = document.getElementsByName("individual");
							var results = [];
							for(var i = 0; i < chks.length-1; i++){
								if(cif_value == document.getElementById("row"+(i+1)+"_individual").value)
								{
									document.getElementById("row"+(i+1)+"_individual").checked = true;
									showDivForRadio();
								}
							}
						}
						else
							showDivForRadio();
					}
				}
				if(WSNAME!="OPS_Maker")
					showDivForRadio();
				onLoadShowShareHoldersDetails();
				showSelectedDocumnets();
				//document.getElementById("MemoPads").value = document.getElementById("wdesk:MemoPad").value;		
				CheckEnableDisable();	
			}
			
			function ajaxRequest(workstepname,reqType)
			{
				var url = '/webdesktop/CustomForms/TL_Specific/HandleAjaxRequest.jsp?workstepname='+workstepname+"&reqType="+reqType;
				var xhr;
				var ajaxResult;			
				var values = "";
				if(window.XMLHttpRequest)
					 xhr=new XMLHttpRequest();
				else if(window.ActiveXObject)
					 xhr=new ActiveXObject("Microsoft.XMLHTTP");
				
				 xhr.open("GET",url,false);
				 xhr.send(null);
				
				if (xhr.status == 200)
				{
					ajaxResult = xhr.responseText;
					ajaxResult = ajaxResult.replace(/^\s+|\s+$/gm,'');
				
					values = ajaxResult.split(",");				
					
					if ( reqType=='getSolId' )
					{
						document.getElementById('wdesk:sol_id').value = values;					
					}
				}
				else
				{
					alert("Error while handling "+reqType+" for the current workstep");
					return false;
				}
			}		
			
			function ClearFields(savedFlagFromDB)
			{	
				document.getElementById("wdesk:CIF_Num").value="";
				document.getElementById("wdesk:Acc_Num").value="";
				document.getElementById("wdesk:RM_Code").value="";
				
				document.getElementById("wdesk:Company_Name").value="";		
				document.getElementById("wdesk:Segment").value="";
				document.getElementById("wdesk:Sub_Segment").value="";
				document.getElementById("wdesk:TL_Num").value="";
				document.getElementById("wdesk:ID_Issued_Org").value="";
				document.getElementById("wdesk:Issue_Date").value="";
				document.getElementById("wdesk:Exis_Expiry_Date").value="";
				document.getElementById("wdesk:New_Expiry_Date").value="";
				document.getElementById("wdesk:isblacklist").value="";
				document.getElementById("wdesk:IsEliteCustomer").value="";
				//Added by Aishwarya for sol_id check
				if(document.getElementById("wdesk:Channel").value!='Business')
					document.getElementById("wdesk:sol_id").value="";
				document.getElementById("wdesk:Mobile_Number").value="";
				document.getElementById("wdesk:email_id").value="";
				
				document.getElementById("wdesk:CIF_Num").disabled = false;
				document.getElementById("wdesk:Acc_Num").disabled = false;
				
				document.getElementById("wdesk:Old_KYC_Expiry_Date").value="";
				document.getElementById("wdesk:New_KYC_Expiry_Date").value="";
				document.getElementById("wdesk:EmiratesUnifiedLicense").value="";
				document.getElementById("wdesk:FederalUnifiedLicense").value="";
				document.getElementById("wdesk:Emirates").value="";
				document.getElementById("wdesk:IndustrySegment").value="";
				document.getElementById("wdesk:IndustrySubsegment").value="";
				
				document.getElementById("Fetch").disabled = false;
				document.getElementById("Clear").disabled = true;
				
				try {
						 var table = document.getElementById("shareholderTab");
						 var rowCount = table.rows.length;
						 for(var i=1; i<rowCount; i++) {
							 var row = table.rows[i];
								 if(rowCount <= 1) {                       
									 break;
								 }
								 table.deleteRow(i);
								 rowCount--;
								 i--;
						 }
						 }catch(e) {
							 alert(e);
						 }
				
				div = document.getElementById('divCheckbox2');
				if(typeof(div) != 'undefined' && div != null)
				div.style.display = "none";
				
				div = document.getElementById('TL_mainGrid');
				if(typeof(div) != 'undefined' && div != null)
				div.style.display = "none";				
			}
			
			function replaceAll(data,searchfortxt,replacetxt)
			{
				var startIndex=0;
				while(data.indexOf(searchfortxt)!=-1)
				{
					data=data.substring(startIndex,data.indexOf(searchfortxt))+data.substring(data.indexOf(searchfortxt)+1,data.length);
				}	
				return data;
			}
				
			 var selectIds = $('#panel1,#panel2,#panel3,#panel4,#panel5,#panel6,#panel7,#panel8,#panel9,#panel10,#panel11,#panel12');
			$(function ($) {
				selectIds.on('show.bs.collapse hidden.bs.collapse', function () {
					$(this).prev().find('.glyphicon').toggleClass('glyphicon-plus glyphicon-minus');
				})
			});
			 	   
			function move(tbFrom, tbTo, button) 
			{
				var arrFrom = new Array(); 
				var arrTo = new Array(); 
				var arrLU = new Array();
				//alert(tbFrom.options.length);
				//alert(tbTo.options.length);
				var idTbFrom=tbFrom.id;
				//var idTbTo=tbTo.id;				
				var i;
				for (i = 0; i < tbTo.options.length; i++) 
				{
					arrLU[tbTo.options[i].text] = tbTo.options[i].value;
					arrTo[i] = tbTo.options[i].text;
				}
				var fLength = 0;
				var tLength = arrTo.length;
				for(i = 0; i < tbFrom.options.length; i++) 
				{
					arrLU[tbFrom.options[i].text] = tbFrom.options[i].value;
					if (tbFrom.options[i].selected && tbFrom.options[i].value != "") 
					{
						arrTo[tLength] = tbFrom.options[i].text;
						tLength++;
					}
					else 
					{
						arrFrom[fLength] = tbFrom.options[i].text;
						fLength++;
					}
				}
				
				tbFrom.length = 0;
				tbTo.length = 0;
				var ii;
				
				for(ii = 0; ii < arrFrom.length; ii++) {
					var no = new Option();
					no.text = arrFrom[ii];
					no.value = arrFrom[ii];
					tbFrom[ii] = no;
				}
				
				for(ii = 0; ii < arrTo.length; ii++) {
					var no = new Option();
					no.text = arrTo[ii];
					no.value = arrTo[ii];
					tbTo[ii] = no;
				}
				
				//Below Code is being used to fetch selected 'Documents list' to save in database.
				var docList = "";
				if(button.id=="addButton") {
					for(j = 0; j < tbTo.length; j++) {
						if(docList != "") {
							docList = docList + "-" + tbTo[j].value;
						}
						else {
							docList = tbTo[j].value;
						}
					}			
				}
				else {		
					for(j = 0; j < tbFrom.length; j++) {
						if(docList != "") {							
							docList = docList + "-" + tbFrom[j].value;
						}						 
						else {
							docList = tbFrom[j].value;
						}
					}
				}
				//alert(idTbFrom);
				if(idTbFrom == 'selectedList')
				{	
					//alert(idTbFrom);
					if(tbFrom.options.length == 0)
					{
						document.getElementById("selectedList").style.Width = "220px";
					}
					else
					{
						document.getElementById("selectedList").style.Width = "auto";
						document.getElementById("documentList").style.Width = "auto";
					}
				}
				if(idTbFrom == 'documentList')
				{
					if(tbFrom.options.length == 0)
					{
						document.getElementById("documentList").style.Width = "220px";
					}
					else
					{
						document.getElementById("documentList").style.Width = "auto";
						document.getElementById("selectedList").style.Width = "auto";
					}
				}
				//alert(tbFrom.options.length);
				document.getElementById("wdesk:Supporting_Docs").value = docList;
			}
				
			function GetPreviousYrTL()
			{
				var cif_num=document.getElementById("wdesk:CIF_Num").value;
				/*if(cif_num==null||cif_num=="") 
				{
					alert("Please enter CIF Number to get Previous Year's Trade License.");
					document.getElementById("wdesk:CIF_Num").focus();
					return;
				}*/
				var WINAME=document.getElementById("wdesk:WI_NAME").value;
				var ajaxResult;
				var xhr;
				if(window.XMLHttpRequest)
					 xhr=new XMLHttpRequest();
				else if(window.ActiveXObject)
					 xhr=new ActiveXObject("Microsoft.XMLHTTP");
					
				var url="/webdesktop/CustomForms/TL_Specific/GetPreviousYrTL.jsp";     
				var param="cif_num="+cif_num+"&WINAME="+WINAME;
				
				xhr.open("POST",url,false);
				xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');		
				xhr.send(param);
				
				if (xhr.status == 200 && xhr.readyState == 4)
				{
					ajaxResult=xhr.responseText;
					ajaxResult=ajaxResult.replace(/^\s+|\s+$/gm,'');
					var status = ajaxResult.split("~");
					if(status[0] != '0')
					{
						if(status[0] == '10'||status[0] == '11'||status[0] == '12')
						{
							alert("Previous Year's Trade License not found");
						}
						else{
							alert("Error in fetching Previous Year Trade License");
						}	
						return false;
					}
					else 
					{
						window.parent.customAddDoc(status[1]);
					}
				}
				else {
					alert("Problem in GetpreviousYrTL.jsp");
					return false;
				}		
				return true;
			}
			
			function GetBlackListDetails()
			{	
				var cif_num=document.getElementById("wdesk:CIF_Num").value;
				//var acc_no=document.getElementById("wdesk:Acc_Num").value;
				if((cif_num==null||cif_num==""))
				{
					alert("Please enter CIF Number or Account Number to search.");
					document.getElementById("wdesk:CIF_Num").focus();
					return;
				}
				
				var xhr;
				var ajaxResult;
				if(window.XMLHttpRequest)
				 xhr=new XMLHttpRequest();
				else if(window.ActiveXObject)
				 xhr=new ActiveXObject("Microsoft.XMLHTTP");
				
				var url="/webdesktop/CustomForms/TL_Specific/isBlackList.jsp";
				var param="cif_num="+cif_num;
				
				xhr.open("POST",url,false);
				xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');		
				xhr.send(param);
				
				if (xhr.status == 200 && xhr.readyState == 4)
				{
					ajaxResult=xhr.responseText;
					ajaxResult=ajaxResult.replace(/^\s+|\s+$/gm,'');
					if(ajaxResult == 'NoRecord')
					{
						alert("No record found.");
						return false;
					}
					else if(ajaxResult == 'Error')
					{
						alert("Some problem in fetch Details.");
						return false;
					}
					else
					{
						document.getElementById("wdesk:isblacklist").value = ajaxResult;
					}				
				}
				else {
					alert("Problem in isBlackList.jsp");
					return false;
				}	
				
				return true;		
			}
			
			function GetMainGrid()
			{
				var txt="", parser, xmlDoc;
				var cif_num=document.getElementById("wdesk:CIF_Num").value;
				var acc_no=document.getElementById("wdesk:Acc_Num").value;
				/*if((cif_num==null||cif_num=="") && (acc_no == null || acc_no == ""))
				{
				alert("Please enter CIF Number or Account Number to search.");
				document.getElementById("wdesk:CIF_Num").focus();
				return;
				}*/
				var xhr;
				var ajaxResult;
				if(window.XMLHttpRequest)
				 xhr=new XMLHttpRequest();
				else if(window.ActiveXObject)
				 xhr=new ActiveXObject("Microsoft.XMLHTTP");
				
				var url="/webdesktop/CustomForms/TL_Specific/mainGridDetails.jsp";
				var param="cif_num="+cif_num+"&acc_no="+acc_no;
				
				xhr.open("POST",url,false);
				xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');		
				xhr.send(param);
				
				if (xhr.status == 200 && xhr.readyState == 4)
				{
				ajaxResult=xhr.responseText;
				ajaxResult=ajaxResult.replace(/^\s+|\s+$/gm,'');
				if(ajaxResult == 'NoRecord')
				{
					alert("No record found.");
					return false;
				}
				else if(ajaxResult == 'Error')
				{
					alert("Some problem in fetch Details.");
					return false;
				}
				else
				{
					var data = ajaxResult.split("^^^");
					ajaxResult = data[0];
					document.getElementById("mainGrid").innerHTML=ajaxResult;
					document.getElementById("mainGridDataForTable").value=data[1];
					//alert(document.getElementById("mainGridDataForTable").value);
					//var status = $(ajaxResult).find("ReturnDesc").text();
					if (window.showModalDialog)
				{ // Internet Explorer
					xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
					xmlDoc.async = "false";
					xmlDoc.loadXML(ajaxResult);
				}
				else 
				{
					// Firefox, Chrome, Opera, etc.
					parser=new DOMParser();
					xmlDoc=parser.parseFromString(ajaxResult,"text/xml"); 
				}
					
				}				
				}
				else {
				alert("Problem in mainGridDetails.jsp");
				return false;
				}
				
				return true;
			}
			
			function GetSearchDetails()
			{	
				var txt, parser, xmlDoc;
				var cif_num=document.getElementById("wdesk:CIF_Num").value;
				var acc_no=document.getElementById("wdesk:Acc_Num").value;
				if((cif_num==null||cif_num=="") && (acc_no == null || acc_no == ""))
				{
					alert("Please enter CIF Number or Account Number to search.");
					document.getElementById("wdesk:CIF_Num").focus();
					return;
				}
				
				
				var xhr;
				var ajaxResult;
				if(window.XMLHttpRequest)
				 xhr=new XMLHttpRequest();
				else if(window.ActiveXObject)
				 xhr=new ActiveXObject("Microsoft.XMLHTTP");
				
				var url="/webdesktop/CustomForms/TL_Specific/searchDetails.jsp";
				var param="cif_num="+cif_num+"&acc_no="+acc_no;
				
				xhr.open("POST",url,false);
				xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');		
				xhr.send(param);
				
				if (xhr.status == 200 && xhr.readyState == 4)
				{
					ajaxResult=xhr.responseText;
					ajaxResult=ajaxResult.replace(/^\s+|\s+$/gm,'');
					if(ajaxResult == 'NoRecord')
					{
						alert("No record found.");
						return false;
					}
					else if(ajaxResult == 'Error')
					{
						alert("Some problem in fetch Details.");
						return false;
					}
					else
					{
						if (window.showModalDialog)
				{ // Internet Explorer
					xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
						xmlDoc.async = "false";
						xmlDoc.loadXML(ajaxResult);
				}
				else 
				{
					// Firefox, Chrome, Opera, etc.
					parser=new DOMParser();
					xmlDoc=parser.parseFromString(ajaxResult,"text/xml"); 
				}
						//var status = $(ajaxResult).find("ReturnDesc").text();
						
					
						var strStatus = xmlDoc.getElementsByTagName("ReturnCode")[0].childNodes[0].nodeValue;
					
						if(strStatus=='0000') {
							
							var companyName = '';
							if(typeof xmlDoc.getElementsByTagName("FullName")[0]!= 'undefined' && xmlDoc.getElementsByTagName("FullName")[0] != null) {
								companyName = xmlDoc.getElementsByTagName("FullName")[0].childNodes[0].nodeValue;
							}
							var accountNo = '';
							if(typeof xmlDoc.getElementsByTagName("ACCNumber")[0]!= 'undefined' && xmlDoc.getElementsByTagName("ACCNumber")[0] != null) {
								accountNo = xmlDoc.getElementsByTagName("ACCNumber")[0].childNodes[0].nodeValue;
							}
							var CIFId = '';
							if(typeof xmlDoc.getElementsByTagName("CIFID")[0]!= 'undefined' && xmlDoc.getElementsByTagName("CIFID")[0] != null) {
								CIFId = xmlDoc.getElementsByTagName("CIFID")[0].childNodes[0].nodeValue;
							}
							var RMName = '';
							if(typeof xmlDoc.getElementsByTagName("ARMCode")[0]!= 'undefined' && xmlDoc.getElementsByTagName("ARMCode")[0] != null) {
								RMName = xmlDoc.getElementsByTagName("ARMCode")[0].childNodes[0].nodeValue;
							}
							var segment = '';
							if(typeof xmlDoc.getElementsByTagName("CustomerSegment")[0]!= 'undefined' && xmlDoc.getElementsByTagName("CustomerSegment")[0] != null) {
								segment = xmlDoc.getElementsByTagName("CustomerSegment")[0].childNodes[0].nodeValue;
							}
							var subSegment = '';
							if(typeof xmlDoc.getElementsByTagName("CustomerSubSeg")[0]!= 'undefined' && xmlDoc.getElementsByTagName("CustomerSubSeg")[0] != null) {
								subSegment = xmlDoc.getElementsByTagName("CustomerSubSeg")[0].childNodes[0].nodeValue;
							}
							var sIndustrySegment = '';
							if(typeof xmlDoc.getElementsByTagName("IndustrySegment")[0]!= 'undefined' && xmlDoc.getElementsByTagName("IndustrySegment")[0] != null) {
								sIndustrySegment = xmlDoc.getElementsByTagName("IndustrySegment")[0].childNodes[0].nodeValue;
							}
							var sIndustrySubSegment = '';
							if(typeof xmlDoc.getElementsByTagName("IndustrySubSegment")[0]!= 'undefined' && xmlDoc.getElementsByTagName("IndustrySubSegment")[0] != null) {
								sIndustrySubSegment = xmlDoc.getElementsByTagName("IndustrySubSegment")[0].childNodes[0].nodeValue;
							}
							
							
							var IsPremium = '';
							if(typeof xmlDoc.getElementsByTagName("IsPremium")[0]!= 'undefined' && xmlDoc.getElementsByTagName("IsPremium")[0] != null) {
								IsPremium = xmlDoc.getElementsByTagName("IsPremium")[0].childNodes[0].nodeValue;
							}
							//Start - Considering B as Y, Changes done on 07112017
							if (IsPremium == "B")
							{
								IsPremium = "Y";
							}
							//End - Considering B as Y, Changes done on 07112017
							
							var solId = '';
							if(typeof xmlDoc.getElementsByTagName("SrcBranch")[0]!= 'undefined' && xmlDoc.getElementsByTagName("SrcBranch")[0] != null) {
								solId = xmlDoc.getElementsByTagName("SrcBranch")[0].childNodes[0].nodeValue;
							}
							
							if(document.getElementById("wdesk:Channel").value == 'Auto Scheduler')
							{
								var SrcBranch = ''
								if(typeof xmlDoc.getElementsByTagName("SrcBranch")[0]!= 'undefined' && xmlDoc.getElementsByTagName("SrcBranch")[0] != null) {
									SrcBranch = xmlDoc.getElementsByTagName("SrcBranch")[0].childNodes[0].nodeValue;
								}
								document.getElementById("wdesk:sol_id").value = SrcBranch;
							}
							
							
							var DocumentDetTags = xmlDoc.getElementsByTagName("DocumentDet");
							var TLNo = "";
							var expiryDate = "";
							var issueDate = "";
							var idIssuedOrg = "";
							var cmregnum = "";
						
							for (var i = 0; i < DocumentDetTags.length; i++) 
							{
								var DocumentDetRowTags = DocumentDetTags[i].childNodes;
								
								if(DocumentDetRowTags[0].childNodes[0].nodeValue == "TradeLicense") 
								{
									for (var j = 0; j < DocumentDetRowTags.length; j++) 
									{
										if(DocumentDetRowTags[j].nodeName == "DocId") {
										 TLNo = DocumentDetRowTags[j].childNodes[0].nodeValue;								
										}
										
										else if(DocumentDetRowTags[j].nodeName == "DocExpDt") {
										 expiryDate = DocumentDetRowTags[j].childNodes[0].nodeValue;								
										}
										
										else if(DocumentDetRowTags[j].nodeName == "DocIssDate") {
										 issueDate = DocumentDetRowTags[j].childNodes[0].nodeValue;								
										}
										
										else if(DocumentDetRowTags[j].nodeName == "IssuedOrganisation") {
										 idIssuedOrg = DocumentDetRowTags[j].childNodes[0].nodeValue;								
										}								
									}
								}
								else if(DocumentDetRowTags[0].childNodes[0].nodeValue == "CMREG")
								{
									for (var j = 0; j < DocumentDetRowTags.length; j++) 
									{
										if(DocumentDetRowTags[j].nodeName == "DocId") {
										 cmregnum = DocumentDetRowTags[j].childNodes[0].nodeValue;								
										}								
									}
								}
							}
							var PhnDet = xmlDoc.getElementsByTagName("PhnDet");
							var PhoneNo="";
							for (var i = 0; i < PhnDet.length; i++) {
								//var addrType = "";
								//addrType = PhnDet[i].getElementsByTagName("AddressType")[0].childNodes[0].nodeValue;
								//if(addrType=="OFFICE") // commented on 14032016 after dicussion with var
								var PhnPrefFlag = "";
								if( typeof PhnDet[i].getElementsByTagName("PhnPrefFlag")[0].childNodes[0] != 'undefined' && PhnDet[i].getElementsByTagName("PhnPrefFlag")[0].childNodes[0] != null )
									PhnPrefFlag = PhnDet[i].getElementsByTagName("PhnPrefFlag")[0].childNodes[0].nodeValue;
									
								if(PhnPrefFlag=="Y")
								{
									
									if( typeof PhnDet[i].getElementsByTagName("PhoneNo")[0].childNodes[0] != 'undefined' && PhnDet[i].getElementsByTagName("PhoneNo")[0].childNodes[0] != null )
									PhoneNo = PhnDet[i].getElementsByTagName("PhoneNo")[0].childNodes[0].nodeValue;
									break;
								}
							}
							var EmailDet = xmlDoc.getElementsByTagName("EmailDet");
							var EmailID="";
							for (var i = 0; i < EmailDet.length; i++) {
								//var addrType = "";
								//addrType = EmailDet[i].getElementsByTagName("AddressType")[0].childNodes[0].nodeValue;
								//if(addrType=="OFFICE") // commented on 14032016 after dicussion with var
								var MailPrefFlag = "";
								MailPrefFlag = EmailDet[i].getElementsByTagName("MailPrefFlag")[0].childNodes[0].nodeValue;
								if(MailPrefFlag=="Y")
								{
									if( typeof EmailDet[i].getElementsByTagName("EmailID")[0].childNodes[0] != 'undefined' && EmailDet[i].getElementsByTagName("EmailID")[0].childNodes[0] != null )
										EmailID = EmailDet[i].getElementsByTagName("EmailID")[0].childNodes[0].nodeValue;
									break;
								}
							}
							
							var kycReviewDateDet = xmlDoc.getElementsByTagName("KYCDet");
							var kycReviewDate="";
							for (var i = 0; i < kycReviewDateDet.length; i++) {
								var isKYCHeld = "";
								isKYCHeld = kycReviewDateDet[i].getElementsByTagName("KYCHeld")[0].childNodes[0].nodeValue;
								if(isKYCHeld=="Y")
								{
									if( typeof kycReviewDateDet[i].getElementsByTagName("KYCReviewDate")[0].childNodes[0] != 'undefined' && kycReviewDateDet[i].getElementsByTagName("KYCReviewDate")[0].childNodes[0] != null )
										kycReviewDate = kycReviewDateDet[i].getElementsByTagName("KYCReviewDate")[0].childNodes[0].nodeValue;
									break;
								}
							}
							
							document.getElementById("wdesk:CIF_Num").value = CIFId;
							document.getElementById("wdesk:Mobile_Number").value = PhoneNo;
							document.getElementById("wdesk:email_id").value = EmailID;
							document.getElementById("wdesk:Acc_Num").value = accountNo;
							document.getElementById("wdesk:RM_Code").value = RMName;
							document.getElementById("wdesk:Company_Name").value = companyName;
							document.getElementById("wdesk:Segment").value = segment;
							document.getElementById("wdesk:Sub_Segment").value = subSegment;
							document.getElementById("wdesk:TL_Num").value = TLNo;
							document.getElementById("wdesk:ID_Issued_Org").value = idIssuedOrg;
							document.getElementById("wdesk:cmreg_num").value = cmregnum;
							document.getElementById("wdesk:Old_KYC_Expiry_Date").value = kycReviewDate;
							document.getElementById("wdesk:IndustrySegment").value = sIndustrySegment;
							document.getElementById("wdesk:IndustrySubsegment").value = sIndustrySubSegment;
							
							//Added by Aishwarya for sol_id check
							if(document.getElementById("wdesk:Channel").value!='Business')
								document.getElementById("wdesk:sol_id").value=solId;
							
							document.getElementById("wdesk:IsEliteCustomer").value = IsPremium;
							//alert(issueDate);
							var strIssueDate = formatDate(issueDate);
							
							document.getElementById("wdesk:Issue_Date").value = strIssueDate;
							var strExpiryDate = formatDate(expiryDate);
							document.getElementById("wdesk:Exis_Expiry_Date").value = strExpiryDate;
							var strkycReviewDate=formatDate(kycReviewDate);
							document.getElementById("wdesk:Old_KYC_Expiry_Date").value =strkycReviewDate;
							getCustomerSummary(); //For Shareholder deatils grid	
							getCustomerDetails(); //for legal entity and risk profile
						}
						else {
							alert('Unable to Search Customer Details');
						}
					}				
				}
				else {
					alert("Problem in GetSearchDetails.jsp");
					return false;
				}	
				
				document.getElementById("wdesk:CIF_Num").disabled = true;
				//document.getElementById("wdesk:Acc_Num").disabled = true;	
				
				document.getElementById("Fetch").disabled = true;
				document.getElementById("Clear").disabled = false;			
				GetBlackListDetails();
				return true;		
			}
			
			function showCustomerSummary(CustomerSummaryResponse)
			{		
				try {
						 var table = document.getElementById("shareholderTab");
						 var rowCount = table.rows.length;
						 for(var i=1; i<rowCount; i++) {
							 var row = table.rows[i];
								 if(rowCount <= 1) {                       
									 break;
								 }
								 table.deleteRow(i);
								 rowCount--;
								 i--;
						 }
						 }catch(e) {
							 alert(e);
						 }
				
				var xmlDoc;
				var parser;
				if (window.showModalDialog)
				{ // Internet Explorer
					xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
					xmlDoc.async=false;
					xmlDoc.loadXML(CustomerSummaryResponse);
				}
				else 
				{
					// Firefox, Chrome, Opera, etc.
					parser=new DOMParser();
					xmlDoc=parser.parseFromString(CustomerSummaryResponse,"text/xml"); 
				}
					
				/*var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
				xmlDoc.async = "false";
				xmlDoc.loadXML(CustomerSummaryResponse);*/
				
				var RCIFDetailsTags = xmlDoc.getElementsByTagName("RCIFDetails");
				
				var gridData = "";
				for (var i = 0; i < RCIFDetailsTags.length; i++) 
				{
					var gridRow = "";
					var row=document.getElementById("shareholderTab").insertRow(i+1);
					
					var RCIFRowTags=RCIFDetailsTags[i].childNodes;
					
					var RCIFId="";
					var Fullname="";
					var FName="";
					var MName="";
					var LName="";
					var SubRelationshipStatus="";
					for (var j = 0; j < RCIFRowTags.length; j++) 
					{  				
						if(RCIFRowTags[j].childNodes==null || RCIFRowTags[j].childNodes.length==0 || RCIFRowTags[j].childNodes[0].nodeValue==null)
							continue;
						
						if(RCIFRowTags[j].nodeName=="RCIFId") {
							RCIFId=RCIFRowTags[j].childNodes[0].nodeValue;
						}
						else if(RCIFRowTags[j].nodeName=="FName") {
							FName=RCIFRowTags[j].childNodes[0].nodeValue;
						}
						else if(RCIFRowTags[j].nodeName=="MName") {
							MName=RCIFRowTags[j].childNodes[0].nodeValue;
						}
						else if(RCIFRowTags[j].nodeName=="LName") {
							LName=RCIFRowTags[j].childNodes[0].nodeValue;
						}
						else if(RCIFRowTags[j].nodeName=="SubRelationshipStatus") {
							SubRelationshipStatus=RCIFRowTags[j].childNodes[0].nodeValue;
						}
					}
					
					Fullname=FName+" "+MName+" "+LName;
					
					var cell = row.insertCell(0);
					cell.className="EWNormalGreenGeneral1";
					cell.style.textAlign="center";
					cell.innerHTML = i+1;
					
					cell = row.insertCell(1);
					cell.className="EWNormalGreenGeneral1";
					cell.style.textAlign="center";
					cell.innerHTML = RCIFId;
					
					cell = row.insertCell(2);
					cell.className="EWNormalGreenGeneral1";
					cell.style.textAlign="left";
					cell.innerHTML = Fullname;
					
					cell = row.insertCell(3);
					cell.className="EWNormalGreenGeneral1";
					cell.style.textAlign="center";
					cell.innerHTML = SubRelationshipStatus;			
					
					gridRow = RCIFId + "`" + Fullname + "`" + SubRelationshipStatus;
					if(gridData != "") {
						gridData = gridData + "#" + gridRow;
					}
					else {
						gridData = gridRow;
					}		
				}
				document.getElementById("wdesk:Share_Holder_Details").value = gridData;	
			}
			
			function getCustomerSummary()
			{
				var txt, parser, xmlDoc;
				var cif_num=document.getElementById("wdesk:CIF_Num").value;
				var xhr;
				var ajaxResult;
				if(window.XMLHttpRequest)
				 xhr=new XMLHttpRequest();
				else if(window.ActiveXObject)
				 xhr=new ActiveXObject("Microsoft.XMLHTTP");
				
				var url="/webdesktop/CustomForms/TL_Specific/customerSummary.jsp"; 
				
				var param="requestType=customerSummary&cif_num="+cif_num;
				
				xhr.open("POST",url,false);
				xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');		
				xhr.send(param);
				//alert(xhr.status);
				if (xhr.status == 200 && xhr.readyState == 4)
				{
				ajaxResult=xhr.responseText;
				ajaxResult=ajaxResult.replace(/^\s+|\s+$/gm,'');
				if(ajaxResult == 'NoRecord')
				{
					alert("No record found.");
					return false;
				}
				else if(ajaxResult == 'Error')
				{
					alert("Some problem in fetch Customer Summary details.");
					return false;
				}
				else {
					if (window.showModalDialog)
				{ // Internet Explorer
					xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
					xmlDoc.async=false;
					xmlDoc.loadXML(ajaxResult);
				}
				else 
				{
					// Firefox, Chrome, Opera, etc.
					parser=new DOMParser();
					xmlDoc=parser.parseFromString(ajaxResult,"text/xml"); 
				}
					var strStatus = xmlDoc.getElementsByTagName("ReturnDesc")[0].childNodes[0].nodeValue;
					
					//var status = $(ajaxResult).find("ReturnDesc").text();
					if(strStatus=='Success'||strStatus=='Successful') {
						showCustomerSummary(ajaxResult);										
					}
					else {
						alert('There is no related party for this CIF');
					}
				}				
				}
				else {
				alert("Problem in customer summary");
				return false;
				}		
				return true;
			}
			function getCustomerDetails()
			{	
					
				var parser, xmlDoc;
				var cif_num=document.getElementById("wdesk:CIF_Num").value;
				if((cif_num==null||cif_num==""))
				{
					alert("Please enter CIF Number or Account Number to search.");
					document.getElementById("wdesk:CIF_Num").focus();
					return;
				}
				var xhr;
				var ajaxResult;
				if(window.XMLHttpRequest)
				 xhr=new XMLHttpRequest();
				else if(window.ActiveXObject)
				xhr=new ActiveXObject("Microsoft.XMLHTTP");
				
				var url = "/webdesktop/CustomForms/TL_Specific/customerSummary.jsp";
				var param = "requestType=customerDetails&cif_num=" + cif_num;
				
				xhr.open("POST",url,false);
				xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');		
				xhr.send(param);
				
				if (xhr.status == 200 && xhr.readyState == 4)
				{
					ajaxResult=xhr.responseText;
					ajaxResult=ajaxResult.replace(/^\s+|\s+$/gm,'');
					if(ajaxResult == 'NoRecord')
					{
						alert("No record found.");
						return false;
					}
					else if(ajaxResult == 'Error')
					{
						alert("Some problem in fetch Details.");
						return false;
					}
					else
					{
						if (window.showModalDialog)
						{ 	// Internet Explorer
							xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
							xmlDoc.async = "false";
							xmlDoc.loadXML(ajaxResult);
						}
						else 
						{
							// Firefox, Chrome, Opera, etc.
							parser=new DOMParser();
							xmlDoc=parser.parseFromString(ajaxResult,"text/xml"); 
						}
						//var status = $(ajaxResult).find("ReturnDesc").text();
						
						var strStatus = xmlDoc.getElementsByTagName("ReturnCode")[0].childNodes[0].nodeValue;

						if(strStatus=='0000') {
						
							var riskProfile = '';
							if(typeof xmlDoc.getElementsByTagName("RiskProfile")[0]!= 'undefined' && xmlDoc.getElementsByTagName("RiskProfile")[0] != null) {
							riskProfile = xmlDoc.getElementsByTagName("RiskProfile")[0].childNodes[0].nodeValue;
							}

							var corpAddnlDet = xmlDoc.getElementsByTagName("CorpAddnlDet");
							var legalEntity="";
							for (var i = 0; i < corpAddnlDet.length; i++) {
								if( typeof corpAddnlDet[i].getElementsByTagName("LegEnt")[0].childNodes[0] != 'undefined' && corpAddnlDet[i].getElementsByTagName("LegEnt")[0].childNodes[0] != null )
									legalEntity = corpAddnlDet[i].getElementsByTagName("LegEnt")[0].childNodes[0].nodeValue;
								break;
							}
						document.getElementById("wdesk:LegalEntity").value = legalEntity;
						document.getElementById("wdesk:RiskScore").value = riskProfile ;						
						}
						else {
							alert('Unable to Search Customer Details');
						}
					}				
				}
				else {
					alert("Problem in customer details");
					return false;
				}		
				return true;		
			}

			
			function onLoadShowShareHoldersDetails() {
				var gridData = document.getElementById("wdesk:Share_Holder_Details").value;
				
				if(gridData != null && gridData != "" && gridData != "null") {
					var values = (gridData).split("#");
					
						var RCIFId="";
						var Fullname="";
						var FName="";
						var MName="";
						var LName="";
						var SubRelationshipStatus="";
					
					for (var i=0 ; i< values.length ; i++) {
						var columns = (values[i]).split("`");				
						var row=document.getElementById("shareholderTab").insertRow(i+1);
						
						RCIFId = columns[0];
						Fullname = columns[1];
						SubRelationshipStatus = columns[2];
					
						var cell = row.insertCell(0);
						cell.className="EWNormalGreenGeneral1";
						cell.style.textAlign="center";
						cell.innerHTML = i+1;
						
						cell = row.insertCell(1);
						cell.className="EWNormalGreenGeneral1";
						cell.style.textAlign="center";
						cell.innerHTML = RCIFId;
						
						cell = row.insertCell(2);
						cell.className="EWNormalGreenGeneral1";
						cell.style.textAlign="left";
						cell.innerHTML = Fullname;
						
						cell = row.insertCell(3);
						cell.className="EWNormalGreenGeneral1";
						cell.style.textAlign="center";
						cell.innerHTML = SubRelationshipStatus;			
					}
				}	
			}
			
			function showSelectedDocumnets() {
				var selectedDocs = document.getElementById("wdesk:Supporting_Docs").value;		
				if(selectedDocs!='') {
					var selectedDocsList = selectedDocs.split("-");
					var select=document.getElementById("selectedList");
					for(var i = 0; i<selectedDocsList.length; i++) {
					
						if(selectedDocsList[i] != "undefined") {
							var option = document.createElement("option");
							option.text = selectedDocsList[i];
							option.value = selectedDocsList[i]; //Not required for Internet Explorer - why??
							select.add(option);
							listWidthAuto = true;
						}				
					}
				}	
				var listWidthAuto = document.getElementById("wdesk:Supporting_Docs").value;
				if(!(listWidthAuto == ""))
				{
					document.getElementById("selectedList").style.Width = "auto";
				}
			}
			
			
			function CheckEnableDisable() {
				if('<%=WSNAME%>' == 'OPS_Maker') {
					var accountNo = document.getElementById("wdesk:Acc_Num").value;
					var CIFId = document.getElementById("wdesk:CIF_Num").value;
					
					if ((accountNo != null && accountNo != "null" && accountNo != "") && (CIFId != null && CIFId != "null" && CIFId != "")) {
						document.getElementById("Fetch").disabled = true;
						document.getElementById("wdesk:CIF_Num").disabled = true;
						}
					else {
						document.getElementById("Fetch").disabled = false;
						document.getElementById("wdesk:CIF_Num").disabled = false;
					}
				}
			}	
			
			function OnDivScroll(id)
			{
				var documentList;
				if(id=="divDocumentList")
					documentList = document.getElementById("documentList");
				else
					documentList = document.getElementById("selectedList");
				
				if (documentList.options.length > 8)
				{
					documentList.size=documentList.options.length;
				}
				else
				{
					documentList.size=8;
				}
			}
			function OnSelectFocus(id)
			{
				var objDiv;
				var documentList;
				if(id=="divDocumentList"){
					objDiv=document.getElementById("divDocumentList");
					documentList=document.getElementById("documentList");
				}
				else{
					objDiv=document.getElementById("divSelectedList");
					documentList=document.getElementById("selectedList");
				}
				
				if (objDiv.scrollLeft != 0)
				{
					objDiv.scrollLeft = 0;
				}
				if( documentList.options.length > 8)
				{
					documentList.focus();
					documentList.size=8;
				}
			}
			function setFrameSize()
			{
				var widthToSet = document.getElementById("TAB_TradeLicense").offsetWidth;
				var controlName="div_TradeLicense,TAB_TradeLicense,TAB_TradeLicenseDetails,TL_mainGrid,div_TradeLicDetails,div_ShareHolderDetails,shareholderTab,div_SupportingDocs,TAB_SupportingDocs,div_DecisionDetails,TAB_DecisionDetails,div_ErrorDescription,TAB_ErrorDescription";
				var fieldArray = controlName.split(",");
				var loopVar=0;
				
				while(loopVar<fieldArray.length)
				{
					if(document.getElementById(fieldArray[loopVar]))
					{
						document.getElementById(fieldArray[loopVar]).style["width"] = widthToSet+"px";
					}				
					loopVar++;	
				}
			}
			function trim(str) {
				if (undefined == str)
					return "";
				return str.replace(/^\s+|\s+$/g, '');
			}
			
			
		</script>
		<script>
			$(document).ready(function()
			{
			    $(window).resize(function()
				{		
					setFrameSize();
				});
			});
		</script>
		
	</head>
	<BODY onload="window.parent.checkIsFormLoaded();setFrameSize();initForm('<%=WSNAME%>','<%=wdmodel.getViewMode()%>');loadDropdownvalues('IndustrySegment');loadDropdownvalues('IndustrySubsegment');loadDropdownvalues('LegalEntity');loadDropdownvalues('Emirates');" id="frmData">
		<form name="wdesk" id="wdesk" method="post">
			<style>
				@import url("/webdesktop/webtop/en_us/css/docstyle.css");
			</style>
			<div class="accordion-group">
				<div class="accordion-heading" id="div_TradeLicense">
					<h4 class="panel-title" align="center"  style="text-align:center;">
						<a class="accordion-toggle"  data-toggle="collapse" data-parent="#accordion" href="#panel19">Trade License
						</a>
					</h4>
				</div>
				<!---  OPS_Maker  -->
				<%	 if(WSNAME.equalsIgnoreCase("OPS_Maker")){%>
				<div id="panel19" class="accordion-body collapse in">
					<div class="accordion-inner">
						<table id="TAB_TradeLicense" border='1' cellspacing='1' cellpadding='0' width="100%" >
							<tr>
								<td colspan =4 width=100% height=100% align=right valign=center><img src='\webdesktop\webtop\images\bank-logo.gif'></td>
							</tr>
							<tr>
								<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Logged In As</b></td>
								<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<%=wDSession.getM_objUserInfo().getM_strUserName()%></td>
								<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Workstep</b></td>
								<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1' height ='22' ><label id="Workstep">&nbsp;&nbsp;&nbsp;&nbsp;<%=wdmodel.getWorkitem().getActivityName().replace("_"," ")%></label></td>
							</tr>
							<tr>											
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>CIF Number</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:CIF_Num" id="wdesk:CIF_Num" <%=strDisableReadOnly%> value='<%=((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()%>' maxlength = '7' onkeypress="if ( isNaN( String.fromCharCode(event.keyCode) )) return false;"></td>			
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Account Number</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Acc_Num" id="wdesk:Acc_Num" <%=strDisableReadOnly%> value='<%=((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()%>' maxlength = '16' onkeypress="if ( isNaN( String.fromCharCode(event.keyCode) )) return false;">
								</td>					
							</tr>
							<tr>							
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>SOL ID</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:sol_id" id="wdesk:sol_id" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()%>'></td>							
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Channel</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Channel" id="wdesk:Channel" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Channel")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Channel")).getValue()%>' maxlength = '12' ></td>
							</tr>
							<tr>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RM Code</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RM_Code" id="wdesk:RM_Code" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()%>' maxlength = '12'></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RAK Elite Customer</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:IsEliteCustomer" id="wdesk:IsEliteCustomer"  maxlength = '16' value='<%=((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()%>' readonly DISABLED=true></td>					
							</tr>
							<tr>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Mobile Number</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Mobile_Number" id="wdesk:Mobile_Number" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()%>'></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Email ID</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:email_id" id="wdesk:email_id" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("email_id")).getValue()%>' maxlength = '100'></td>											
							</tr>
							<tr>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Blacklisted/<br>&nbsp;&nbsp;Negated Customer</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:isblacklist" id="wdesk:isblacklist" value='<%=((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()%>' readonly DISABLED=true  maxlength = '100'></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
							</tr>
							<tr>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
								<td style="text-align:right;" nowrap='nowrap' class='EWNormalGreenGeneral1'><input name='Fetch' type='button' id='Fetch' value='Search' onclick="GetMainGrid();" class='EWButtonRB' <%=strDisableReadOnly%> style='width:85px' ></td>
								<td style="text-align:left;" nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;&nbsp;&nbsp;<input name='Clear' id='Clear' type='button' value='Clear' onclick="ClearFields()" class='EWButtonRB' <%=strDisableReadOnly%> style='width:85px' ></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input name='GetOLDTL' id='GetOLDTL' type='button' value='Get Old TL' onclick="GetPreviousYrTL()" class='EWButtonRB' <%=strDisableReadOnly%> style='width:85px' ></td>
							</tr>
						</table>
					</div>
				</div>
				<div id="divCheckbox" style="display: none;">
					<div class="accordion-group">
						<div class="accordion-heading">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel20">List of CIFs
								</a>
							</h4>
						</div>
						<div id="panel20" class="accordion-body collapse in">
							<div class="accordion-inner">
								<table width="100%" border='1' cellspacing='1' cellpadding='0'>
									<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
										<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Select</b></td>
										<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Number</b></td>
										<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Name</b></td>
										<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Type</b></td>
									</tr>
									<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
										<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="radio" name="individual" value="Individual" id="individual" onclick="javascript:showDivForRadio();"></td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>5003089</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Julius Ceasar</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Individual</td>
									</tr>
								</table>
							</div>
						</div>
					</div>
				</div>
				<div class="accordion-group">
					<div id="panel20" class="accordion-body collapse in">
						<div class="accordion-inner" id="mainGrid">
							<%
								//String mainGridvalue="";
								Query="SELECT CIFID,CustomerName,CustomerType FROM usr_0_tl_listofcifs with(nolock) WHERE WI_NAME='"+WINAME+"'";
								
								inputData = "<?xml version='1.0'?><APSelectWithColumnNames_Input><Option>APSelectWithColumnNames</Option><Query>" + Query + "</Query><EngineName>" + wDSession.getM_objCabinetInfo().getM_strCabinetName() + "</EngineName><SessionId>" + wDSession.getM_objUserInfo().getM_strSessionId() + "</SessionId></APSelectWithColumnNames_Input>";
								WriteLog("inputData-"+inputData);
								//outputData = WFCallBroker.execute(inputData, wfsession.getJtsIp(), wfsession.getJtsPort(), 1);
							outputData =	 NGEjbClient.getSharedInstance().makeCall(wDSession.getM_objCabinetInfo().getM_strServerIP(), wDSession.getM_objCabinetInfo().getM_strServerPort(), wDSession.getM_objCabinetInfo().getM_strAppServerType(), inputData);
								WriteLog("Output-TL-"+outputData);
								
								objXmlParser=null;
								
								xmlParserData=new XMLParser();
								xmlParserData.setInputXML((outputData));
								
								subXML="";
								String cif_num="";
								String cus_name="";
								String cif_type="";
								
								//String rowVal="";
								//String temp_table="";
								//String MainRadio = "";
								//row=0;
								
								String mainCodeValue = xmlParserData.getValueOf("MainCode");
								if(mainCodeValue.equals("0"))
								{
									int recordcount = Integer.parseInt(xmlParserData.getValueOf("TotalRetrieved"));
									subXML = xmlParserData.getNextValueOf("Record");
									
									if(recordcount>0){
									%>
							<table id='TL_mainGrid' width='100%' name='TL_mainGrid' border=1>
								<tr class='EWNormalGreenGeneral1'>
									<th nowrap='nowrap' width="20%" >Select</th>
									<th nowrap='nowrap' width="20%" >CIF Number</th>
									<th nowrap='nowrap' width="40%" >Name</th>
									<th nowrap='nowrap' width="20%" >CIF Type</th>
								</tr>
								<%}		
									for(int k=0; k<recordcount; k++)
									{	
										if(k!=0)
											subXML = xmlParserData.getNextValueOf("Record");
										
										objXmlParser = new XMLParser(subXML);
										
										cif_num = objXmlParser.getValueOf("CIFID");
										cus_name = objXmlParser.getValueOf("CustomerName");
										cif_type = objXmlParser.getValueOf("CustomerType");
										
										if(k==0)
										{
										%>
								<tr class='EWNormalGreenGeneral1'>
									<td><input type='radio' name='individual' value='<%=cif_num%>' id='row<%=(k+1)%>_individual' onclick='javascript:showDivForGrid(this);' checked></td>
									<td><%=cif_num%></td>
									<td><%=cus_name%></td>
									<td><%=cif_type%></td>
								</tr>
								<%
									}
									else {
									%>
								<tr class='EWNormalGreenGeneral1'>
									<td><input type='radio' name='individual' value='<%=cif_num%>' id='row<%=(k+1)%>_individual' onclick='javascript:showDivForGrid(this);' ></td>
									<td><%=cif_num%></td>
									<td><%=cus_name%></td>
									<td><%=cif_type%></td>
								</tr>
								<%
									}	
									}
									
									if(recordcount>0){
									%>
							</table>
							<%}			
								}
								
								/*if(outputData.contains("<TotalRetrieved>0</TotalRetrieved>"))
								{
									mainGridvalue = "";
								}
								else
								{
									while(outputData.contains("<Record>"))
									{
										row++;
										rowVal = outputData.substring(outputData.indexOf("<Record>"),outputData.indexOf("</Record>")+"</Record>".length());
										
										cif_num = rowVal.substring(rowVal.indexOf("<CIFID>")+"</CIFID>".length()-1,rowVal.indexOf("</CIFID>"));
										cus_name = rowVal.substring(rowVal.indexOf("<CustomerName>")+"</CustomerName>".length()-1,rowVal.indexOf("</CustomerName>"));
										cif_type = rowVal.substring(rowVal.indexOf("<CustomerType>")+"</CustomerType>".length()-1,rowVal.indexOf("</CustomerType>"));
										if(row==1)
											MainRadio = "<td><input type='radio' name='individual' value="+"'"+cif_num+"'"+" id="+"'row"+row+"_individual'"+" onclick='javascript:showDivForGrid(this);' checked></td>";
										else
											MainRadio = "<td><input type='radio' name='individual' value="+"'"+cif_num+"'"+" id="+"'row"+row+"_individual'"+" onclick='javascript:showDivForGrid(this);'></td>";
										temp_table = temp_table + "<tr class='EWNormalGreenGeneral1'>"+MainRadio+"<td>"+cif_num+"</td><td>"+cus_name+"</td><td>"+cif_type+"</td></tr>" ;
										
										outputData = outputData.replaceAll(rowVal, "");
									}
									String appendStr = "<table id='TL_mainGrid' width='100%' name='TL_mainGrid' border=1><tr class='EWNormalGreenGeneral1'><th>Select</th><th>CIF Number</th><th>Name</th><th>CIF Type</th></tr>";
								
									
									WriteLog("Table Main : "+appendStr+temp_table+"</table>");
									mainGridvalue = appendStr+temp_table+"</table>";
								}*/
								
								%>
							<!--%= mainGridvalue%-->
						</div>
					</div>
				</div>
				<div id="divCheckbox2" style="display: none;">
					<div class="accordion-group">
						<div class="accordion-heading" id="div_TradeLicDetails">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel3">Trade License Details</a>
							</h4>
						</div>
						<div id="panel3" class="accordion-body collapse in">
							<div class="accordion-inner">
								<table id="TAB_TradeLicenseDetails" border='1' cellspacing='1' cellpadding='0' width=100%>
									<tr>
										<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'>Company Name</td>
										<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Company_Name" maxlength = '100' id="wdesk:Company_Name" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()%>'></td>
										<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1'>Trade License Number</td>
										<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1'><input type="text" name="wdesk:TL_Num" maxlength = '100' id="wdesk:TL_Num"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()%>'></td>
										
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>Segment</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Segment" maxlength = '100' id="wdesk:Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Segment")).getValue()%>'>
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Sub-Segment</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Sub_Segment" maxlength = '100' id="wdesk:Sub_Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()%>'>
										</td>										
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>ID Issued Organisation</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:ID_Issued_Org" maxlength = '100' id="wdesk:ID_Issued_Org" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()%>' >
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Issue Date</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Issue_Date" maxlength = '100' id="wdesk:Issue_Date" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()%>'  >
										</td>
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(Existing)</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Exis_Expiry_Date" maxlength = '100' id="wdesk:Exis_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()%>'  >
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(New)</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_Expiry_Date" maxlength = '100' size="17" id="wdesk:New_Expiry_Date" readonly DISABLED <%=strDisableReadOnly%> value='<%=((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()%>'  >
											<% if(!"R".equalsIgnoreCase(readOnlyFlag)){%>
											<img style="cursor:pointer" strHideReadOnly src='/webdesktop/webtop/images/images/cal.gif' onclick = "initialize('wdesk:New_Expiry_Date');" width='16' height='16' border='0' alt='' >
											<%}%>
										</td>
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(Old)</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Old_KYC_Expiry_Date" maxlength = '100' id="wdesk:Old_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()%>'  >
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(New)</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_KYC_Expiry_Date" maxlength = '100' id="wdesk:New_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()%>'  >
										</td>
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Legal Entity</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
											<select name="wdesk:LegalEntity" id="wdesk:LegalEntity" disabled>
												<option value="">-- Select Legal Entity--</option>
											</select>
										</td>
										
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Risk Score</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RiskScore" maxlength = '100' id="wdesk:RiskScore"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue()%>'  >
										</td>
									 </tr>	 
									<tr width=100%>
										<td  nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Segment
										<td   nowrap='nowrap' class='EWNormalGreenGeneral1'>
											<select style = "maxlength='12'" name="wdesk:IndustrySegment" id="wdesk:IndustrySegment" disabled>
												<option style= "maxlength='12'" value="">-- Select Industry --</option>
											</select>
										</td>	
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Subsegment</td>
										<td   style= "width: 30%;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
											<select  maxlength='12' name="wdesk:IndustrySubsegment" id="wdesk:IndustrySubsegment" disabled>
												<option  maxlength='12' value="">-- Select Industry --</option>
											</select>
										</td>
									</tr>
									
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Emirates
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:EmiratesUnifiedLicense" maxlength = '100' id="wdesk:EmiratesUnifiedLicense"    value='<%=((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()%>'  >
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Federal</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:FederalUnifiedLicense" maxlength = '100' id="wdesk:FederalUnifiedLicense" value='<%=((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()%>'  >
										</td>
									</tr>
									<tr width=100%>		
										<td class='EWNormalGreenGeneral1 width23'>Unified License - Issuing Emirate</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
												<select id="Emirates" name="Emirates" style="width: 130px;" onchange="changeVal(this,'wdesk:Emirates')"  >
													<option  value="--Select--" selected >--Select--</option>
													<option  value="Abu Dhabi" selected >Abu Dhabi</option>
													<option  value="Dubai" selected >Dubai</option>
													<option  value="Sharjah" selected >Sharjah</option>
													<option  value="Ajiman" selected >Ajiman</option>
													<option  value="Umm Al Quwain" selected >Umm Al Quwain</option>
													<option  value="Ras Al Khaimah" selected >Ras Al Khaimah</option>
													<option  value="Fujairah" selected >Fujairah</option>
													</option>
												</select>
										</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
									</tr>
							</table>
							</div>
						</div>
					</div>
					<div class="accordion-group">
						<div class="accordion-heading" id="div_ShareHolderDetails">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel6">Shareholders Details</a>
							</h4>
						</div>
						<div id="panel6" class="accordion-body collapse in">
							<div class="accordion-inner">
								<table id="shareholderTab" border='1' cellspacing='1' cellpadding='0' width=100% >
									<tr>
										<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="10%" ><b>S.No.</b></td>
										<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>CIF ID</b></td>
										<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Name</b></td>
										<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Relationship Type</b></td>
									</tr>
								</table>
							</div>
						</div>
					</div>
					<div class="accordion-group" >
						<div class="accordion-heading" id="div_SupportingDocs">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel7">Supporting Documents Required</a>
							</h4>
						</div>
						<div id="panel7" class="accordion-body collapse">
							<div class="accordion-inner">
								<table id="TAB_SupportingDocs" border='1' cellspacing='1' cellpadding='0' width="100%" >
									<tr width="100%">
										<td colspan =3 style="text-align:right; width: 45%";" nowrap='nowrap' class='EWNormalGreenGeneral1' style=>							
										<p align="right"><b>List of Possible Documents&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></p>
										<!--div style="OVERFLOW: auto; HEIGHT: 100; WIDTH: 200px"-->
										<!--select multiple  size=8 style="WIDTH: 220px" id="documentList" name="FromLB" -->
										<div id='divDocumentList' style="OVERFLOW: auto;WIDTH: 220px;HEIGHT: 147px" onscroll="OnDivScroll(this.id);" >
											<SELECT id='documentList' style="width:auto;" size="8" multiple name="FromLB" onfocus="OnSelectFocus();" >
												<%
													//WriteLog("documentValues.length "+documentValues.length);
													for(int i=0;i<documentValues.length;i++){
														boolean toAdd=true;
														if(selectedDocumentValues!=null && selectedDocumentValues.length>0)
														{
															//WriteLog("documentValues[i] "+documentValues[i]);
															for(int j=0;j<selectedDocumentValues.length;j++){
																if(selectedDocumentValues[j].equalsIgnoreCase(documentValues[i])) 
																{
																	//WriteLog("selectedDocumentValues[j] "+selectedDocumentValues[j]);
																	toAdd=false;
																	break;
																}		
															}
														}	
														if(!toAdd) continue;
													%>
												<option value="<%=documentValues[i]%>"><%=documentValues[i]%></option>
												<%}%>
											</select>
										</div>
										<!--/div-->
										</td>
										<td style="text-align:center; width: 10%;" nowrap='nowrap' class='EWNormalGreenGeneral1' valign="middle"> 
											<%
											String strDisableAddRemove = "";
											if(WSNAME.equalsIgnoreCase("OPS_Maker")){
												strDisableAddRemove="disabled";
											}
											%>	
											<input type="button" <%=strDisableAddRemove%>  id="addButton" class='EWButtonRB' <%=strDisableReadOnly%> style='width:100px' onClick="move(this.form.FromLB,this.form.ToLB,this)" 
												value="Add >>"><br />
											<input type="button" <%=strDisableAddRemove%> id="removeButton" class='EWButtonRB' <%=strDisableReadOnly%> style='width:100px' onClick="move(this.form.ToLB,this.form.FromLB, this)" 
												value="<< Remove">
										</td>
										<td style="text-align:left; width: 45%;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
											<p><b>List of Selected Documents</b></p>
											<div id='divSelectedList' style="OVERFLOW: auto;WIDTH: 220px;HEIGHT: 147px" onscroll="OnDivScroll(this.id);" >
												<!--select multiple size="8" id="selectedList" name="ToLB" style="width:220px"-->
												<SELECT id='selectedList' style="width:auto;" size="8" multiple name="ToLB" onfocus="OnSelectFocus(this.id);" >
												</select>
											</div>
										</td>
									</tr>
								</table>
							</div>
						</div>
					</div>
					<div class="accordion-group">
						<div class="accordion-heading" id="div_DecisionDetails">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel22">Decision Details</a>
							</h4>
						</div>
						<div id="panel22" class="accordion-body collapse in">
							<div class="accordion-inner">
								<table id="TAB_DecisionDetails" border='1' cellspacing='1' cellpadding='0' width=100% >
									<tr>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'width="23%"><b>Decision</b></td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
											<select id="DecisionDropDown" name="DecisionDropDown" style="width: 130px;"  <%=strDisableReadOnly%> onchange="changeVal(this,'<%=WSNAME%>')"  >
												<%for(int i=0;i<DecisionCombo.length;i++){
													if(DecisionCombo[i].trim().equalsIgnoreCase("Decision"))%>
												<option  selected="Activity Completed" value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option> <!--CR change on 15112016-->
												<%}%>
											</select>
											<input name='decision_history' id='decision_history' type='button' value='Decision History' onclick="HistoryCaller()" class='EWButtonRB' style='width:100px' >
										</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Reject Reason
										</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
											<select disabled id="rejectreason" name="rejectreason" onchange="changeVal(this,'<%=WSNAME%>')" <%=strDisableReadOnly%> style="width: 175px;" >
												<option value="--Select--" selected>--Select--</option>
												<%for(int i=0;i<DecisionCombo.length;i++){
													if(DecisionCombo[i].trim().equalsIgnoreCase("Reject Reason"))%>
												<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
												<%	}%>										
											</select>
										</td>
									</tr>
									<tr>
										<td  nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Remarks</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
											<textarea id ="wdesk:Remarks" maxlength="3000" onblur="trimLength(this.id,this.value,3000);" name ="wdesk:Remarks" <%=strDisableReadOnly%> style="width: 100%;"  rows="5" cols="50"></textarea>
										</td>
										<td width="23%" nowrap='nowrap' class='EWNormalGreenGeneral1'>Memopads</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
											<textarea id ="MemoPads" disabled name ="MemoPads" style="width: 100%;"  rows="5" cols="50"><%=((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()%></textarea>
										</td>
									</tr>
									<tr>
									<td width="23%" nowrap='nowrap' class='EWNormalGreenGeneral1'>BOT Remarks</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
											<textarea id ="wdesk:RPA_failDesc" disabled name ="wdesk:RPA_failDesc" style="width: 100%;"  rows="5" cols="50"><%=((WorkdeskAttribute)attributeMap.get("RPA_failDesc")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RPA_failDesc")).getValue()%></textarea>
										</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
									</tr>
								</table>
							</div>
						</div>
					</div>
				</div>
				<input type="hidden" name="wdesk:cmreg_num" maxlength = '100' id="wdesk:cmreg_num"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("cmreg_num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("cmreg_num")).getValue()%>'  >
				<!-- OPS_Checker starts -->
				<%}  else if(WSNAME.equalsIgnoreCase("OPS_Checker")){%>			
				<div id="panel19" class="accordion-body collapse in">
					<div class="accordion-inner">
						<table id="TAB_TradeLicense" border='1' cellspacing='1' cellpadding='0' width="100%" >
							<tr>
								<td colspan =4 width=100% height=100% align=right valign=center><img src='\webdesktop\webtop\images\bank-logo.gif'></td>
							</tr>
							<tr>
								<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Logged In As</b></td>
								<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<%=wDSession.getM_objUserInfo().getM_strUserName()%></td>
								<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Workstep</b></td>
								<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1' height ='22' ><label id="Workstep">&nbsp;&nbsp;&nbsp;&nbsp;<%=wdmodel.getWorkitem().getActivityName().replace("_"," ")%></label></td>
							</tr>

							<tr>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>CIF Number</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:CIF_Num" id="wdesk:CIF_Num" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()%>' maxlength = '7'></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Account Number</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Acc_Num" id="wdesk:Acc_Num" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()%>' maxlength = '16'></td>							
							</tr>							
							<tr>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>SOL ID</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:sol_id" id="wdesk:sol_id" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()%>'></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Channel</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Channel" id="wdesk:Channel" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Channel")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Channel")).getValue()%>' maxlength = '12' ></td>
								
								
							</tr>
							<tr>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RM Code</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RM_Code" id="wdesk:RM_Code" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()%>' maxlength = '12'></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RAK Elite Customer</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:IsEliteCustomer" id="wdesk:IsEliteCustomer"  maxlength = '16' value='<%=((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()%>' readonly DISABLED=true></td>						
							</tr>
							<tr>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Mobile Number</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Mobile_Number" id="wdesk:Mobile_Number" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()%>'></td>
								
								<% if(!(((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null) && !(((WorkdeskAttribute)attributeMap.get("email_id")).getValue().equals(""))) 
								{%>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Email ID</b></td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:email_id" id="wdesk:email_id" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("email_id")).getValue()%>' maxlength = '100'></td>
								<% }
								else 
								{%>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
								<%}%>
							</tr>
							<tr>								
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Blacklisted/<br>&nbsp;&nbsp;Negated Customer</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:isblacklist" id="wdesk:isblacklist" value='<%=((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()%>' readonly DISABLED=true  maxlength = '100'></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
							</tr>
							<tr>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
								<td style="text-align:right;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
									<input name='Fetch' type='button' id='Fetch' readonly DISABLED=true value='Search' class='EWButtonRB' style='width:85px' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								</td>
								<td style="text-align:left;" nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;&nbsp;&nbsp;
									<input name='Clear' id='Clear' readonly DISABLED=true type='button' value='Clear' onclick="ClearFields()" class='EWButtonRB' style='width:85px' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input name='GetOLDTL' id='GetOLDTL' type='button' DISABLED value='Get Old TL' onclick="GetPreviousYrTL()" class='EWButtonRB' style='width:85px' >
								</td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
							</tr>
						</table>
					</div>
				</div>
			
				<div id="divCheckbox" style="display: none;">
					<div class="accordion-group">
						<div class="accordion-heading">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel20">List of CIFs
								</a>
							</h4>
						</div>
						<div id="panel20" class="accordion-body collapse in">
							<div class="accordion-inner">
								<table width="100%" border='1' cellspacing='1' cellpadding='0'>
									<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
										<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Select</b></td>
										<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Number</b></td>
										<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Name</b></td>
										<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Type</b></td>
									</tr>
									<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
										<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="radio" name="individual" value="Individual" id="individual" onclick="javascript:showDivForRadio();"></td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>5003089</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Julius Ceasar</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Individual</td>
									</tr>
								</table>
							</div>
						</div>
					</div>
				</div>
				<div id="divCheckbox2" style="display: none;">
					<div class="accordion-group">
						<div class="accordion-heading" id="div_TradeLicDetails">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel3">Trade License Details</a>
							</h4>
						</div>
						<div id="panel3" class="accordion-body collapse in">
							<div class="accordion-inner">
								<table id="TAB_TradeLicenseDetails" border='1' cellspacing='1' cellpadding='0' width=100%>
									<tr>
										<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'>Company Name</td>
										<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Company_Name" maxlength = '100' id="wdesk:Company_Name" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()%>'></td>
										<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1'>Trade License Number</td>
										<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1'><input type="text" name="wdesk:TL_Num" maxlength = '100' id="wdesk:TL_Num"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()%>'></td>										
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>Segment</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Segment" maxlength = '100' id="wdesk:Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Segment")).getValue()%>'></td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Sub-Segment</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Sub_Segment" maxlength = '100' id="wdesk:Sub_Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()%>'></td>	

									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>ID Issued Organisation</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:ID_Issued_Org" maxlength = '100' id="wdesk:ID_Issued_Org" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()%>' >
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Issue Date</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Issue_Date" maxlength = '100' id="wdesk:Issue_Date" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()%>'  >
										</td>
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(Existing)</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Exis_Expiry_Date" maxlength = '100' id="wdesk:Exis_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()%>'  >
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(New)</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
											<input type="text" name="wdesk:New_Expiry_Date" maxlength = '100' id="wdesk:New_Expiry_Date" readonly DISABLED value='<%=((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()%>'  >
											<!--<img style="cursor:pointer" src='/webdesktop/webtop/images/images/cal.gif' onclick = "initialize('wdesk:New_Expiry_Date');" width='16' height='16' border='0' alt='' > -->
										</td>
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(Old)</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Old_KYC_Expiry_Date" maxlength = '100' id="wdesk:Old_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()%>'  >
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(New)</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_KYC_Expiry_Date" maxlength = '100' id="wdesk:New_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()%>'  >
										</td>
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Legal Entity</td>
										
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
                                        <select name="wdesk:LegalEntity" id="wdesk:LegalEntity" disabled>
                                        <option value="">-- Select Legal Entity --</option>
                                        </select>
                                        </td>
										
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Risk Score</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RiskScore" maxlength = '100' id="wdesk:RiskScore"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue()%>'  >
										</td>
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Segment
										</td>
										
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
                                        <select name="wdesk:IndustrySegment" id="wdesk:IndustrySegment" disabled>
                                        <option value="">-- Select Industry --</option>
                                         </select>
                                         </td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Subsegment</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
                                         <select name="wdesk:IndustrySubsegment" id="wdesk:IndustrySubsegment" disabled>
                                         <option value="">-- Select Industry --</option>
                                         </select>
                                        </td>
										
									</tr>
									
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Emirates
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:EmiratesUnifiedLicense" maxlength = '100' id="wdesk:EmiratesUnifiedLicense"  readonly DISABLED=true   value='<%=((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()%>'  >
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Federal</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:FederalUnifiedLicense" maxlength = '100' id="wdesk:FederalUnifiedLicense"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()%>'  >
										</td>
									</tr>
									<tr width=100%>		
										<td class='EWNormalGreenGeneral1 width23'>Unified License - Issuing Emirate</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' DISABLED width="23%">
												<select id="Emirates" name="Emirates" style="width: 130px;" onchange="changeVal(this,'wdesk:Emirates')" disabled >
													<option  value="--Select--" selected >--Select--</option>
													<option  value="Abu Dhabi" selected >Abu Dhabi</option>
													<option  value="Dubai" selected >Dubai</option>
													<option  value="Sharjah" selected >Sharjah</option>
													<option  value="Ajiman" selected >Ajiman</option>
													<option  value="Umm Al Quwain" selected >Umm Al Quwain</option>
													<option  value="Ras Al Khaimah" selected >Ras Al Khaimah</option>
													<option  value="Fujairah" selected >Fujairah</option>
													</option>
												</select>
										</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
									</tr>
							</table>
							</div>
						</div>
					</div>
					<div class="accordion-group">
						<div class="accordion-heading" id="div_ShareHolderDetails">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel6">Shareholders Details
								</a>
							</h4>
						</div>
						<div id="panel6" class="accordion-body collapse">
							<div class="accordion-inner">
								<table id="shareholderTab" border='1' cellspacing='1' cellpadding='0' width=100% >
									<tr width=100%>
										<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="10%" ><b>S.No.</b></td>
										<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>CIF ID</b></td>
										<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Name</b></td>
										<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Relationship Type</b></td>
									</tr>
								</table>
							</div>
						</div>
					</div>
					<div class="accordion-group" >
						<div class="accordion-heading" id="div_SupportingDocs">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel7">Supporting Documents Required
								</a>
							</h4>
						</div>
						<div id="panel7" class="accordion-body collapse">
							<div class="accordion-inner">
								<table id="TAB_SupportingDocs" border='1' cellspacing='1' cellpadding='0' width="100%" >
									<tr width="100%">
										<td colspan =3 style="text-align:right; width: 45%";" nowrap='nowrap' class='EWNormalGreenGeneral1' style=>
										<p align="right"><b>List of Possible Documents&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></p>
										<div id='divDocumentList' style="OVERFLOW: auto;WIDTH: 220px;HEIGHT: 147px" onscroll="OnDivScroll(this.id);" >
											<select multiple size="8" id='documentList' name="FromLB" style="width:auto">
												<%
													for(int i=0;i<documentValues.length;i++){
														boolean toAdd=true;
														if(selectedDocumentValues!=null && selectedDocumentValues.length>0)
														{
															//WriteLog("documentValues[i] "+documentValues[i]);
															for(int j=0;j<selectedDocumentValues.length;j++){
																if(selectedDocumentValues[j].equalsIgnoreCase(documentValues[i])) 
																{
																	//WriteLog("selectedDocumentValues[j] "+selectedDocumentValues[j]);
																	toAdd=false;
																	break;
																}		
															}
														}	
														if(!toAdd) continue;	
													%>
												<option value="<%=documentValues[i]%>"><%=documentValues[i]%></option>
												<%}%>
											</select>
										</div>
										</td>
										<td style="text-align:center; width: 10%;" nowrap='nowrap' class='EWNormalGreenGeneral1' valign="middle"> 
											<input type="button"  id="addButton" class='EWButtonRB' <%=strDisableReadOnly%> style='width:100px' onClick="move(this.form.FromLB,this.form.ToLB,this)" 
												value="Add >>"><br />
											<input type="button" id="removeButton" class='EWButtonRB' <%=strDisableReadOnly%> style='width:100px' onClick="move(this.form.ToLB,this.form.FromLB, this)" 
												value="<< Remove">
										</td>
										<td style="text-align:center; width: 45%;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
											<p><b>List of Selected Documents</b></p>
											<div id='divSelectedList' style="OVERFLOW: auto;WIDTH: 220px;HEIGHT: 147px" onscroll="OnDivScroll(this.id);" >
												<select id="selectedList" multiple size="8" name="ToLB" style="width:auto;">
												</select>
											</div>
										</td>
									</tr>
								</table>
							</div>
						</div>
					</div>
					<div class="accordion-group">
						<div class="accordion-heading" id="div_DecisionDetails">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel22">Decision Details</a>
							</h4>
						</div>
						<div id="panel22" class="accordion-body collapse in">
							<div class="accordion-inner">
								<table id="TAB_DecisionDetails" border='1' cellspacing='1' cellpadding='0' width=100% >
									<tr>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'width="23%"><b>Decision</b></td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
											<select id="DecisionDropDown" name="DecisionDropDown" <%=strDisableReadOnly%> style="width: 130px;"  onchange="changeVal(this,'<%=WSNAME%>')"  >
												<option value="--Select--" selected >--Select--</option>
												<%for(int i=0;i<DecisionCombo.length;i++){
													if(DecisionCombo[i].trim().equalsIgnoreCase("Decision"))%>
												<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
												<%}%>
											</select>
											<input name='decision_history' id='decision_history' type='button' value='Decision History' onclick="HistoryCaller()" class='EWButtonRB' style='width:100px' >
										</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Reject Reason
										</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
											<input type="hidden" name="wdesk:rejectReason" id="wdesk:rejectReason" value=''>
											<select disabled id="rejectreason" name="rejectreason" onchange="changeVal(this,'<%=WSNAME%>')" <%=strDisableReadOnly%> style="width: 175px;" >
												<option value="--Select--" selected>--Select--</option>
												<%for(int i=0;i<DecisionCombo.length;i++){
													if(DecisionCombo[i].trim().equalsIgnoreCase("Reject Reason"))%>
												<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
												<%	}%>										
											</select>
										</td>
									</tr>
									<tr>
										<td  nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Remarks</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
											<textarea id ="wdesk:Remarks" maxlength="3000" onblur="trimLength(this.id,this.value,3000);" name ="wdesk:Remarks" <%=strDisableReadOnly%> style="width: 100%;"  rows="5" cols="50"></textarea>
										</td>
										<td width="23%" nowrap='nowrap' class='EWNormalGreenGeneral1'>Memopads</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
											<textarea id ="MemoPads" disabled name ="MemoPads" style="width: 100%;"  rows="5" cols="50"><%=((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()%></textarea>
										</td>
									</tr>
								</table>
							</div>
						</div>
					</div>
				</div>
			<!--- End OPS_CHECKER  -->
			<!-- Error starts -->
			<%} else if(WSNAME.equalsIgnoreCase("Error")){%>
			<div id="panel19" class="accordion-body collapse in">
				<div class="accordion-inner">
					<table id="TAB_TradeLicense" border='1' cellspacing='1' cellpadding='0' width="100%" >
						<tr>
							<td colspan =4 width=100% height=100% align=right valign=center><img src='\webdesktop\webtop\images\bank-logo.gif'></td>
						</tr>
						<tr>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Logged In As</b></td>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<%=wDSession.getM_objUserInfo().getM_strUserName()%></td>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Workstep</b></td>
							<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1' height ='22' ><label id="Workstep">&nbsp;&nbsp;&nbsp;&nbsp;<%=wdmodel.getWorkitem().getActivityName().replace("_"," ")%></label></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>CIF Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:CIF_Num" id="wdesk:CIF_Num" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()%>' maxlength = '7'></td>						
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Account Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Acc_Num" id="wdesk:Acc_Num" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()%>' maxlength = '16'></td>					
						</tr>							
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>SOL ID</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:sol_id" id="wdesk:sol_id" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()%>'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Channel</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Channel" id="wdesk:Channel" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Channel")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Channel")).getValue()%>' maxlength = '12' ></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RM Code</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RM_Code" id="wdesk:RM_Code" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()%>' maxlength = '12'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RAK Elite Customer</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:IsEliteCustomer" id="wdesk:IsEliteCustomer"  maxlength = '16' value='<%=((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()%>' readonly DISABLED=true></td>
							
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Mobile Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Mobile_Number" id="wdesk:Mobile_Number" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()%>'></td>
							
							<% if(!(((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null) && !(((WorkdeskAttribute)attributeMap.get("email_id")).getValue().equals(""))) 
							{%>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Email ID</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:email_id" id="wdesk:email_id" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("email_id")).getValue()%>' maxlength = '100'></td>
							<% }
							else
							{%>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
							<%}%>
						</tr>
						<tr>							
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Blacklisted/<br>&nbsp;&nbsp;Negated Customer</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:isblacklist" id="wdesk:isblacklist" value='<%=((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()%>' readonly DISABLED=true  maxlength = '100'></td>							
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
							<td style="text-align:right;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
								<input name='Fetch' type='button' id='Fetch' readonly DISABLED=true value='Search' class='EWButtonRB' style='width:85px' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							</td>
							<td style="text-align:left;" nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;&nbsp;&nbsp;
								<input name='Clear' id='Clear'readonly DISABLED=true type='button' value='Clear'  class='EWButtonRB' style='width:85px' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<input name='GetOLDTL' id='GetOLDTL' readonly DISABLED=true type='button' value='Get Old TL' class='EWButtonRB' style='width:85px' >
							</td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
						</tr>
					</table>
				</div>
			</div>
			<div id="divCheckbox" style="display: none;">
				<div class="accordion-group">
					<div class="accordion-heading">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel20">List of CIFs</a>
						</h4>
					</div>
					<div id="panel20" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table width="100%" border='1' cellspacing='1' cellpadding='0'>
								<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Select</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Number</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Name</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Type</b></td>
								</tr>
								<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="radio" name="individual" value="Individual" id="individual" onclick="javascript:showDivForRadio();"></td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>5003089</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Julius Ceasar</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Individual</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
			<div id="divCheckbox2" style="display: none;">
				<div class="accordion-group">
					<div class="accordion-heading" id="div_TradeLicDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel3">Trade License Details</a>
						</h4>
					</div>
					<div id="panel3" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table id="TAB_TradeLicenseDetails" border='1' cellspacing='1' cellpadding='0' width=100%>
								<tr>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'>Company Name</td>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Company_Name" maxlength = '100' id="wdesk:Company_Name" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()%>'></td>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1'>Trade License Number</td>
									<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1'><input type="text" name="wdesk:TL_Num" maxlength = '100' id="wdesk:TL_Num"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()%>'></td>									
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap'  class='EWNormalGreenGeneral1' height ='22'>Segment</td>
									<td nowrap='nowrap'  class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Segment" maxlength = '100' id="wdesk:Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Segment")).getValue()%>'></td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Sub-Segment</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Sub_Segment" maxlength = '100' id="wdesk:Sub_Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()%>'>
									</td>									
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>ID Issued Organisation</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:ID_Issued_Org" maxlength = '100' id="wdesk:ID_Issued_Org" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()%>' >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Issue Date</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Issue_Date" maxlength = '100' id="wdesk:Issue_Date" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(Existing)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Exis_Expiry_Date" maxlength = '100' id="wdesk:Exis_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()%>'  >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(New)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_Expiry_Date" maxlength = '100' id="wdesk:New_Expiry_Date" readonly DISABLED value='<%=((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(Old)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Old_KYC_Expiry_Date" maxlength = '100' id="wdesk:Old_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()%>'  >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(New)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_KYC_Expiry_Date" maxlength = '100' id="wdesk:New_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Legal Entity</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
                                        <select name="wdesk:LegalEntity" id="wdesk:LegalEntity" disabled>
                                        <option value="">-- Select Legal Entity --</option>
                                        </select>
                                     </td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Risk Score</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RiskScore" maxlength = '100' id="wdesk:RiskScore"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Segment
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' disabled width="23%">
										<select name="wdesk:IndustrySegment" id="wdesk:IndustrySegment" disabled style="width: 100px;">
										<option value="">-- Select Industry --</option>
										</select>
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Subsegment</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' disabled width="23%">
										<select name="wdesk:IndustrySubsegment" id="wdesk:IndustrySubsegment" disabled style="width: 100px;">
										<option value="">-- Select Industry --</option>
										</select>
									</td>
								</tr>
									
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Emirates
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:EmiratesUnifiedLicense" maxlength = '100' id="wdesk:EmiratesUnifiedLicense"  readonly DISABLED=true   value='<%=((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()%>'  >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Federal</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:FederalUnifiedLicense" maxlength = '100' id="wdesk:FederalUnifiedLicense"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>		
									<td class='EWNormalGreenGeneral1 width23'>Unified License - Issuing Emirate</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'   disabled width="23%">
											<select id="Emirates" name="Emirates" style="width: 130px;" onchange="changeVal(this,'wdesk:Emirates')" disabled >
												<option  value="--Select--" selected >--Select--</option>
												<option  value="Abu Dhabi" selected >Abu Dhabi</option>
												<option  value="Dubai" selected >Dubai</option>
												<option  value="Sharjah" selected >Sharjah</option>
												<option  value="Ajiman" selected >Ajiman</option>
												<option  value="Umm Al Quwain" selected >Umm Al Quwain</option>
												<option  value="Ras Al Khaimah" selected >Ras Al Khaimah</option>
												<option  value="Fujairah" selected >Fujairah</option>
												</option>
											</select>
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group">
					<div class="accordion-heading" id="div_ShareHolderDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel6">Shareholders Details</a>
						</h4>
					</div>
					<div id="panel6" class="accordion-body collapse">
						<div class="accordion-inner">
							<table id="shareholderTab" border='1' cellspacing='1' cellpadding='0' width=100% >
								<tr width=100%>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="10%" ><b>S.No.</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>CIF ID</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Name</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Relationship Type</b></td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group" >
					<div class="accordion-heading" id="div_SupportingDocs">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel7">Supporting Documents Required
							</a>
						</h4>
					</div>
					<div id="panel7" class="accordion-body collapse">
						<div class="accordion-inner">
							<table id="TAB_SupportingDocs" border='1' cellspacing='1' cellpadding='0' width="100%" >
								<tr width="100%">
									<td style="text-align:center; width: 45%;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
										<p><b>List of Selected Documents</b></p>
										<div id='divSelectedList' style="OVERFLOW: auto;WIDTH: 304px;HEIGHT: 147px" onscroll="OnDivScroll(this.id);" >
											<select id="selectedList" multiple size="8" name="ToLB" style="width:auto;">
											</select>
										</div>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group">
					<div class="accordion-heading" id="div_ErrorDescription">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel6">Error Description</a>
						</h4>
					</div>
					<div id="panel6" class="accordion-body collapse">
						<div class="accordion-inner">
							<table id="TAB_ErrorDescription" border='1' cellspacing='1' cellpadding='0' width=100% >
								<tr width=100%>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="20%" ><b>Date-Time</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="20%"><b>Call-Name</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="20%"><b>Attributes</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="20%"><b>Status</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Error Description</b></td>
								</tr>
								<%
									Query="SELECT TOP 1 call_name_1 AS 'Call-Name',cif_id AS 'Attribute', call_status_1 AS 'Status', error_desc_1 AS 'Error Description', CallDatetime AS 'Datetime' FROM usr_0_tl_integration_status with (nolock) WHERE WI_name = '"+ WINAME +"' UNION SELECT call_name_2 AS 'Call-Name',accnt_no AS 'Attribute', call_status_2 AS 'Status', error_desc_2 AS 'Error Description' ,CallDatetime AS 'Datetime' FROM usr_0_tl_integration_status with (nolock) WHERE WI_name = '"+ WINAME +"'";
									
									inputData = "<?xml version='1.0'?><APSelectWithColumnNames_Input><Option>APSelectWithColumnNames</Option><Query>" + Query + "</Query><EngineName>" + wDSession.getM_objCabinetInfo().getM_strCabinetName()+ "</EngineName><SessionId>" + wDSession.getM_objUserInfo().getM_strSessionId() + "</SessionId></APSelectWithColumnNames_Input>";
									WriteLog("inputData-"+inputData);
									
								//	outputData = WFCallBroker.execute(inputData, wfsession.getJtsIp(), wfsession.getJtsPort(), 1);

								outputData = NGEjbClient.getSharedInstance().makeCall(wDSession.getM_objCabinetInfo().getM_strServerIP(), wDSession.getM_objCabinetInfo().getM_strServerPort(), wDSession.getM_objCabinetInfo().getM_strAppServerType(), inputData);
									WriteLog("Output-TL-"+outputData);
									
									objXmlParser=null;
									
									xmlParserData=new XMLParser();
									xmlParserData.setInputXML((outputData));
									
									subXML="";
									String strCallName="";
									String strAttribute="";
									String strStatus="";
									String strErrordescription="";
									String strDate_time1="";
									
									String mainCodeValue = xmlParserData.getValueOf("MainCode");
									if(mainCodeValue.equals("0"))
									{
										int recordcount = Integer.parseInt(xmlParserData.getValueOf("TotalRetrieved"));
										subXML = xmlParserData.getNextValueOf("Record");
										
										for(int k=0; k<recordcount; k++)
										{	
											if(k!=0)
												subXML = xmlParserData.getNextValueOf("Record");
											
											objXmlParser = new XMLParser(subXML);
											
											strCallName=objXmlParser.getValueOf("Call-Name");
											strAttribute= objXmlParser.getValueOf("Attribute");
											strStatus= objXmlParser.getValueOf("Status");
											strErrordescription= objXmlParser.getValueOf("Error Description");
											strDate_time1=objXmlParser.getValueOf("Datetime");
											if(strErrordescription==null || strErrordescription.equals(""))	strErrordescription="&nbsp;";
											%>
								<tr >
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><%=strDate_time1%></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><%=strCallName%></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><%=strAttribute%></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><%=strStatus%></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><%=strErrordescription%></td>
								</tr>
								<%
									}
									}
									%>				
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group">
					<div class="accordion-heading" id="div_DecisionDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel22">Decision Details</a>
						</h4>
					</div>
					<div id="panel22" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table id="TAB_DecisionDetails" border='1' cellspacing='1' cellpadding='0' width=100% >
								<tr>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'width="23%"><b>Decision</b></td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
										<select id="DecisionDropDown" name="DecisionDropDown" <%=strDisableReadOnly%> style="width: 130px;"  onchange="changeVal(this,'<%=WSNAME%>')"  >
											<option value="--Select--" selected >--Select--</option>
											<%for(int i=0;i<DecisionCombo.length;i++){
												if(DecisionCombo[i].trim().equalsIgnoreCase("Decision"))%>
											<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
											<%}%>
										</select>
										<input name='decision_history' id='decision_history' type='button' value='Decision History' onclick="HistoryCaller()" class='EWButtonRB' style='width:100px' >
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Reject Reason
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
										<input type="hidden" name="wdesk:rejectReason" id="wdesk:rejectReason" value=''>
										<select disabled id="rejectreason" <%=strDisableReadOnly%> name="rejectreason" style="width: 175px;" >
											<option value="--Select--" selected>--Select--</option>
											<%for(int i=0;i<DecisionCombo.length;i++){
												if(DecisionCombo[i].trim().equalsIgnoreCase("Reject Reason"))%>
											<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
											<%	}%>										
										</select>
									</td>
								</tr>
								<tr>
									<td  nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Remarks</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
										<textarea id ="wdesk:Remarks" maxlength="3000" onblur="trimLength(this.id,this.value,3000);" name ="wdesk:Remarks" <%=strDisableReadOnly%> style="width: 100%;"  rows="5" cols="50"></textarea>
									</td>
									<td width="23%" nowrap='nowrap' class='EWNormalGreenGeneral1'>Memopads</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
										<textarea id ="MemoPads" disabled name ="MemoPads" style="width: 100%;"  rows="5" cols="50"><%=((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()%></textarea>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
			<%} else if(WSNAME.equalsIgnoreCase("Hold") || WSNAME.equalsIgnoreCase("Sys_Hold")){%>
			<div id="panel19" class="accordion-body collapse in">
				<div class="accordion-inner">
					<table id="TAB_TradeLicense" border='1' cellspacing='1' cellpadding='0' width="100%" >
						<tr>
							<td colspan =4 width=100% height=100% align=right valign=center><img src='\webdesktop\webtop\images\bank-logo.gif'></td>
						</tr>
						<tr>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Logged In As</b></td>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<%=wDSession.getM_objUserInfo().getM_strUserName()%></td>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Workstep</b></td>
							<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1' height ='22' ><label id="Workstep">&nbsp;&nbsp;&nbsp;&nbsp;<%=wdmodel.getWorkitem().getActivityName().replace("_"," ")%></label></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>CIF Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:CIF_Num" id="wdesk:CIF_Num" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()%>' maxlength = '7'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Account Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Acc_Num" id="wdesk:Acc_Num" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()%>' maxlength = '16'></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>SOL ID</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:sol_id" id="wdesk:sol_id" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()%>'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Channel</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Channel" id="wdesk:Channel" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Channel")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Channel")).getValue()%>' maxlength = '12' ></td>
						</tr>
						<tr>						
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RM Code</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RM_Code" id="wdesk:RM_Code" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()%>' maxlength = '12'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RAK Elite Customer</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:IsEliteCustomer" id="wdesk:IsEliteCustomer"  maxlength = '16' value='<%=((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()%>' readonly DISABLED=true></td>							
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Mobile Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Mobile_Number" id="wdesk:Mobile_Number" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()%>'></td>
						
							
							<% if(!(((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null) && !(((WorkdeskAttribute)attributeMap.get("email_id")).getValue().equals(""))) 
							{%>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Email ID</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:email_id" id="wdesk:email_id" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("email_id")).getValue()%>' maxlength = '100'></td>
							<% } 
							else
							{%>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>							
							<% }%>
						</tr>
						<tr>
							
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Blacklisted/<br>&nbsp;&nbsp;Negated Customer</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:isblacklist" id="wdesk:isblacklist" value='<%=((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()%>' readonly DISABLED=true  maxlength = '100'></td>	
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
							<td style="text-align:right;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
								<input name='Fetch' type='button' id='Fetch' readonly DISABLED=true value='Search' class='EWButtonRB' style='width:85px' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							</td>
							<td style="text-align:left;" nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;&nbsp;&nbsp;
								<input name='Clear' id='Clear'readonly DISABLED=true type='button' value='Clear'  class='EWButtonRB' style='width:85px' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<input name='GetOLDTL' id='GetOLDTL' readonly DISABLED=true type='button' value='Get Old TL' class='EWButtonRB' style='width:85px' >
							</td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
						</tr>
					</table>
				</div>
			</div>
			<div id="divCheckbox" style="display: none;">
				<div class="accordion-group">
					<div class="accordion-heading">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel20">List of CIFs</a>
						</h4>
					</div>
					<div id="panel20" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table width="100%" border='1' cellspacing='1' cellpadding='0'>
								<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Select</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Number</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Name</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Type</b></td>
								</tr>
								<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="radio" name="individual" value="Individual" id="individual" onclick="javascript:showDivForRadio();"></td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>5003089</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Julius Ceasar</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Individual</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
			<div id="divCheckbox2" style="display: none;">
				<div class="accordion-group">
					<div class="accordion-heading" id="div_TradeLicDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel3">Trade License Details</a>
						</h4>
					</div>
					<div id="panel3" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table id="TAB_TradeLicenseDetails" border='1' cellspacing='1' cellpadding='0' width=100%>
								<tr>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'>Company Name</td>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Company_Name" maxlength = '100' id="wdesk:Company_Name" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()%>'></td>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1'>Trade License Number</td>
									<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1'><input type="text" name="wdesk:TL_Num" maxlength = '100' id="wdesk:TL_Num"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()%>'></td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap'  class='EWNormalGreenGeneral1' height ='22'>Segment</td>
									<td nowrap='nowrap'  class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Segment" maxlength = '100' id="wdesk:Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Segment")).getValue()%>'></td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Sub-Segment</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Sub_Segment" maxlength = '100' id="wdesk:Sub_Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()%>'></td>									
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>ID Issued Organisation</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:ID_Issued_Org" maxlength = '100' id="wdesk:ID_Issued_Org" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()%>' >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Issue Date</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Issue_Date" maxlength = '100' id="wdesk:Issue_Date" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(Existing)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Exis_Expiry_Date" maxlength = '100' id="wdesk:Exis_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()%>'  >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(New)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_Expiry_Date" maxlength = '100' id="wdesk:New_Expiry_Date" readonly DISABLED value='<%=((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(Old)</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Old_KYC_Expiry_Date" maxlength = '100' id="wdesk:Old_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()%>'  >
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(New)</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_KYC_Expiry_Date" maxlength = '100' id="wdesk:New_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()%>'  >
										</td>
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Legal Entity</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
                                        <select name="wdesk:LegalEntity" id="wdesk:LegalEntity" disabled>
                                        <option value="">-- Select Legal Entity --</option>
                                        </select>
                                        </td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Risk Score</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RiskScore" maxlength = '100' id="wdesk:RiskScore"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue()%>'  >
										</td>
									</tr>
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Segment
										</td>
										
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
                                        <select name="wdesk:IndustrySegment" id="wdesk:IndustrySegment" disabled>
                                        <option value="">-- Select Industry --</option>
                                         </select>
                                         </td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Subsegment</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
                                         <select name="wdesk:IndustrySubsegment" id="wdesk:IndustrySubsegment" disabled>
                                         <option value="">-- Select Industry --</option>
                                         </select>
                                        </td>
									</tr>
									
									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Emirates</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:EmiratesUnifiedLicense" maxlength = '100' id="wdesk:EmiratesUnifiedLicense"  readonly DISABLED=true   value='<%=((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()%>'  >
										</td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Federal</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:FederalUnifiedLicense" maxlength = '100' id="wdesk:FederalUnifiedLicense"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()%>'  >
										</td>
									</tr>
									<tr width=100%>		
										<td class='EWNormalGreenGeneral1 width23'>Unified License - Issuing Emirate</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' DISABLED width="23%">
												<select id="Emirates" name="Emirates" style="width: 130px;" onchange="changeVal(this,'wdesk:Emirates')" disabled >
													<option  value="--Select--" selected >--Select--</option>
													<option  value="Abu Dhabi" selected >Abu Dhabi</option>
													<option  value="Dubai" selected >Dubai</option>
													<option  value="Sharjah" selected >Sharjah</option>
													<option  value="Ajiman" selected >Ajiman</option>
													<option  value="Umm Al Quwain" selected >Umm Al Quwain</option>
													<option  value="Ras Al Khaimah" selected >Ras Al Khaimah</option>
													<option  value="Fujairah" selected >Fujairah</option>
													</option>
												</select>
										</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
									</tr>
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group">
					<div class="accordion-heading" id="div_ShareHolderDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel6">Shareholders Details</a>
						</h4>
					</div>
					<div id="panel6" class="accordion-body collapse">
						<div class="accordion-inner">
							<table id="shareholderTab" border='1' cellspacing='1' cellpadding='0' width=100% >
								<tr width=100%>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="10%" ><b>S.No.</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>CIF ID</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Name</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Relationship Type</b></td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group" >
					<div class="accordion-heading" id="div_SupportingDocs">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel7">Supporting Documents Required
							</a>
						</h4>
					</div>
					<div id="panel7" class="accordion-body collapse">
						<div class="accordion-inner">
							<table id="TAB_SupportingDocs" border='1' cellspacing='1' cellpadding='0' width="100%" >
								<tr width="100%">
									<td style="text-align:center; width: 45%;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
										<p><b>List of Selected Documents</b></p>
										<div id='divSelectedList' style="OVERFLOW: auto;WIDTH: 304px;HEIGHT: 147px" onscroll="OnDivScroll(this.id);" >
											<select id="selectedList" multiple size="8" name="ToLB" style="width:auto;">
											</select>
										</div>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group">
					<div class="accordion-heading" id="div_DecisionDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel22">Decision Details</a>
						</h4>
					</div>
					<div id="panel22" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table id="TAB_DecisionDetails" border='1' cellspacing='1' cellpadding='0' width=100% >
								<tr>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'width="23%"><b>Decision</b></td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
										<select id="DecisionDropDown" name="DecisionDropDown" <%=strDisableReadOnly%> style="width: 130px;"  onchange="changeVal(this,'<%=WSNAME%>')"  >
											<option value="--Select--" selected >--Select--</option>
											<%for(int i=0;i<DecisionCombo.length;i++){
												if(DecisionCombo[i].trim().equalsIgnoreCase("Decision"))%>
											<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
											<%}%>
										</select>
										<input name='decision_history' id='decision_history' type='button' value='Decision History' onclick="HistoryCaller()" class='EWButtonRB' style='width:100px' >
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Reject Reason
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
										<input type="hidden" name="wdesk:rejectReason" id="wdesk:rejectReason" value=''>
										<select disabled id="rejectreason" <%=strDisableReadOnly%> name="rejectreason" style="width: 175px;" >
											<option value="--Select--" selected>--Select--</option>
											<%for(int i=0;i<DecisionCombo.length;i++){
												if(DecisionCombo[i].trim().equalsIgnoreCase("Reject Reason"))%>
											<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
											<%	}%>										
										</select>
									</td>
								</tr>
								<tr>
									<td  nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Remarks</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
										<textarea id ="wdesk:Remarks" maxlength="3000" onblur="trimLength(this.id,this.value,3000);" name ="wdesk:Remarks" <%=strDisableReadOnly%> style="width: 100%;"  rows="5" cols="50"></textarea>
									</td>
									<td width="23%" nowrap='nowrap' class='EWNormalGreenGeneral1'>Memopads</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
										<textarea id ="MemoPads" disabled name ="MemoPads" style="width: 100%;"  rows="5" cols="50"><%=((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()%></textarea>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
			<%} else if(WSNAME.equalsIgnoreCase("Rejected_TL")){%>
			<div id="panel19" class="accordion-body collapse in">
				<div class="accordion-inner">
					<table id="TAB_TradeLicense" border='1' cellspacing='1' cellpadding='0' width="100%" >
						<tr>
							<td colspan =4 width=100% height=100% align=right valign=center><img src='\webdesktop\webtop\images\bank-logo.gif'></td>
						</tr>
						<tr>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Logged In As</b></td>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<%=wDSession.getM_objUserInfo().getM_strUserName()%></td>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Workstep</b></td>
							<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1' height ='22' ><label id="Workstep">&nbsp;&nbsp;&nbsp;&nbsp;<%=wdmodel.getWorkitem().getActivityName().replace("_"," ")%></label></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>CIF Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:CIF_Num" id="wdesk:CIF_Num" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()%>' maxlength = '7'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Account Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Acc_Num" id="wdesk:Acc_Num" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()%>' maxlength = '16'></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>SOL ID</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:sol_id" id="wdesk:sol_id" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()%>'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Channel</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Channel" id="wdesk:Channel" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Channel")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Channel")).getValue()%>' maxlength = '12' ></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RM Code</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RM_Code" id="wdesk:RM_Code" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()%>' maxlength = '12'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RAK Elite Customer</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:IsEliteCustomer" id="wdesk:IsEliteCustomer"  maxlength = '16' value='<%=((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()%>' readonly DISABLED=true></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Mobile Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Mobile_Number" id="wdesk:Mobile_Number" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()%>'></td>
							<% if(!(((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null) && !(((WorkdeskAttribute)attributeMap.get("email_id")).getValue().equals(""))) 
							{%>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Email ID</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:email_id" id="wdesk:email_id" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("email_id")).getValue()%>' maxlength = '100'></td>
							<% } 
							else
							{%>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
							<% }%>
						</tr>
						<tr>							
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Blacklisted/<br>&nbsp;&nbsp;Negated Customer</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:isblacklist" id="wdesk:isblacklist" value='<%=((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()%>' readonly DISABLED=true  maxlength = '100'></td>							
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
							<td style="text-align:right;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
								<input name='Fetch' type='button' id='Fetch' readonly DISABLED=true value='Search' class='EWButtonRB' style='width:85px' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							</td>
							<td style="text-align:left;" nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;&nbsp;&nbsp;
								<input name='Clear' id='Clear'readonly DISABLED=true type='button' value='Clear'  class='EWButtonRB' style='width:85px' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<input name='GetOLDTL' id='GetOLDTL' readonly DISABLED=true type='button' value='Get Old TL' class='EWButtonRB' style='width:85px' >
							</td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
						</tr>
					</table>
				</div>
			</div>
			<div id="divCheckbox" style="display: none;">
				<div class="accordion-group">
					<div class="accordion-heading">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel20">List of CIFs
							</a>
						</h4>
					</div>
					<div id="panel20" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table width="100%" border='1' cellspacing='1' cellpadding='0'>
								<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Select</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Number</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Name</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Type</b></td>
								</tr>
								<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="radio" name="individual" value="Individual" id="individual" onclick="javascript:showDivForRadio();"></td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>5003089</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Julius Ceasar</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Individual</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
			<div id="divCheckbox2" style="display: none;">
				<div class="accordion-group">
					<div class="accordion-heading" id="div_TradeLicDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel3">Trade License Details</a>
						</h4>
					</div>
					<div id="panel3" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table id="TAB_TradeLicenseDetails" border='1' cellspacing='1' cellpadding='0' width=100%>
								<tr>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'>Company Name</td>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Company_Name" maxlength = '100' id="wdesk:Company_Name" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()%>'></td>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1'>Trade License Number</td>
									<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1'><input type="text" name="wdesk:TL_Num" maxlength = '100' id="wdesk:TL_Num"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()%>'></td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap'  class='EWNormalGreenGeneral1' height ='22'>Segment</td>
									<td  nowrap='nowrap'  class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Segment" maxlength = '100' id="wdesk:Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Segment")).getValue()%>'></td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Sub-Segment</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Sub_Segment" maxlength = '100' id="wdesk:Sub_Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()%>'></td>									
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>ID Issued Organisation</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:ID_Issued_Org" maxlength = '100' id="wdesk:ID_Issued_Org" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()%>' >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Issue Date</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Issue_Date" maxlength = '100' id="wdesk:Issue_Date" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(Existing)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Exis_Expiry_Date" maxlength = '100' id="wdesk:Exis_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()%>'  >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(New)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_Expiry_Date" maxlength = '100' id="wdesk:New_Expiry_Date" readonly DISABLED value='<%=((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(Old)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Old_KYC_Expiry_Date" maxlength = '100' id="wdesk:Old_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()%>'  >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(New)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_KYC_Expiry_Date" maxlength = '100' id="wdesk:New_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Legal Entity</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
                                        <select name="wdesk:LegalEntity" id="wdesk:LegalEntity" disabled>
                                        <option value="">-- Select Legal Entity --</option>
                                        </select>
                                        </td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Risk Score</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RiskScore" maxlength = '100' id="wdesk:RiskScore"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Segment
										</td>
										
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
                                        <select name="wdesk:IndustrySegment" id="wdesk:IndustrySegment" disabled>
                                        <option value="">-- Select Industry --</option>
                                         </select>
                                         </td>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Subsegment</td>
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
                                         <select name="wdesk:IndustrySubsegment" id="wdesk:IndustrySubsegment" disabled>
                                         <option value="">-- Select Industry --</option>
                                         </select>
                                        </td>
								</tr>
									
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Emirates </td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:EmiratesUnifiedLicense" maxlength = '100' id="wdesk:EmiratesUnifiedLicense"  readonly DISABLED=true   value='<%=((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()%>'  >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Federal</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:FederalUnifiedLicense" maxlength = '100' id="wdesk:FederalUnifiedLicense"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>		
									<td class='EWNormalGreenGeneral1 width23'>Unified License - Issuing Emirate</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'   DISABLED width="23%">
											<select id="Emirates" name="Emirates" style="width: 130px;" onchange="changeVal(this,'wdesk:Emirates')"  disabled >
												<option  value="--Select--" selected >--Select--</option>
												<option  value="Abu Dhabi" selected >Abu Dhabi</option>
												<option  value="Dubai" selected >Dubai</option>
												<option  value="Sharjah" selected >Sharjah</option>
												<option  value="Ajiman" selected >Ajiman</option>
												<option  value="Umm Al Quwain" selected >Umm Al Quwain</option>
												<option  value="Ras Al Khaimah" selected >Ras Al Khaimah</option>
												<option  value="Fujairah" selected >Fujairah</option>
												</option>
											</select>
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group">
					<div class="accordion-heading" id="div_ShareHolderDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel6">Shareholders Details
							</a>
						</h4>
					</div>
					<div id="panel6" class="accordion-body collapse">
						<div class="accordion-inner">
							<table id="shareholderTab" border='1' cellspacing='1' cellpadding='0' width=100% >
								<tr width=100%>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="10%" ><b>S.No.</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>CIF ID</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Name</b></td>
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1' colspan="1" width="30%"><b>Relationship Type</b></td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group" >
					<div class="accordion-heading" id="div_SupportingDocs">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel7">Supporting Documents Required
							</a>
						</h4>
					</div>
					<div id="panel7" class="accordion-body collapse">
						<div class="accordion-inner">
							<table id="TAB_SupportingDocs" border='1' cellspacing='1' cellpadding='0' width="100%" >
								<tr width="100%">
									<td style="text-align:center; width: 45%;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
										<p><b>List of Selected Documents</b></p>
										<div id='divSelectedList' style="OVERFLOW: auto;WIDTH: 304px;HEIGHT: 147px" onscroll="OnDivScroll(this.id);" >
											<select id="selectedList" multiple size="8" name="ToLB" style="width:auto;">
											</select>
										</div>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group">
					<div class="accordion-heading" id="div_DecisionDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel22">Decision Details</a>
						</h4>
					</div>
					<div id="panel22" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table id="TAB_DecisionDetails" border='1' cellspacing='1' cellpadding='0' width=100% >
								<tr>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'width="23%"><b>Decision</b></td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
										<select id="DecisionDropDown" name="DecisionDropDown" <%=strDisableReadOnly%> style="width: 130px;"  onchange="changeVal(this,'<%=WSNAME%>')"  >
											<option value="--Select--" selected >--Select--</option>
											<%for(int i=0;i<DecisionCombo.length;i++){
												if(DecisionCombo[i].trim().equalsIgnoreCase("Decision"))%>
											<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
											<%}%>
										</select>
										<input name='decision_history' id='decision_history' type='button' value='Decision History' onclick="HistoryCaller()" class='EWButtonRB' style='width:100px' >
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Reject Reason
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
										<input type="hidden" name="wdesk:rejectReason" id="wdesk:rejectReason" value=''>
										<select disabled id="rejectreason" name="rejectreason" style="width: 175px;" >
											<option value="--Select--" selected>--Select--</option>
											<%for(int i=0;i<DecisionCombo.length;i++){
												if(DecisionCombo[i].trim().equalsIgnoreCase("Reject Reason"))%>
											<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
											<%	}%>										
										</select>
									</td>
								</tr>
								<tr>
									<td  nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Remarks</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
										<textarea id ="wdesk:Remarks" maxlength="3000" onblur="trimLength(this.id,this.value,3000);" name ="wdesk:Remarks" <%=strDisableReadOnly%> style="width: 100%;"  rows="5" cols="50"></textarea>
									</td>
									<td width="23%" nowrap='nowrap' class='EWNormalGreenGeneral1'>Memopads</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
										<textarea id ="MemoPads" disabled name ="MemoPads" style="width: 100%;"  rows="5" cols="50"><%=((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()%></textarea>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
			<!---  End Rejected TL  -->
			<%} else{%>
			<div id="panel19" class="accordion-body collapse in">
				<div class="accordion-inner">
					<table id="TAB_TradeLicense" border='1' cellspacing='1' cellpadding='0' width="100%" >
						<tr>
							<td colspan =4 width=100% height=100% align=right valign=center><img src='\webdesktop\webtop\images\bank-logo.gif'></td>
						</tr>
						<tr>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Logged In As</b></td>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<%=wDSession.getM_objUserInfo().getM_strUserName()%></td>
							<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22' >&nbsp;&nbsp;<b>Workstep</b></td>
							<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1' height ='22' ><label id="Workstep">&nbsp;&nbsp;&nbsp;&nbsp;<%=wdmodel.getWorkitem().getActivityName().replace("_"," ")%></label></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>CIF Number </b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:CIF_Num" id="wdesk:CIF_Num" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("CIF_Num")).getValue()%>' maxlength = '7'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Account Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Acc_Num" id="wdesk:Acc_Num" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Acc_Num")).getValue()%>' maxlength = '16'></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>SOL ID</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:sol_id" id="wdesk:sol_id" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("sol_id")).getValue()%>'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Channel</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Channel" id="wdesk:Channel" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Channel")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Channel")).getValue()%>' maxlength = '12' ></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RM Code</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RM_Code" id="wdesk:RM_Code" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("RM_Code")).getValue()%>' maxlength = '12'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>RAK Elite Customer</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:IsEliteCustomer" id="wdesk:IsEliteCustomer"  maxlength = '16' value='<%=((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("IsEliteCustomer")).getValue()%>' readonly DISABLED=true></td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Mobile Number</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Mobile_Number" id="wdesk:Mobile_Number" readonly DISABLED=true  maxlength = '100' value='<%=((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Mobile_Number")).getValue()%>'></td>
							<% if(!(((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null) && !(((WorkdeskAttribute)attributeMap.get("email_id")).getValue().equals(""))) 
							{%>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Email ID</b></td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:email_id" id="wdesk:email_id" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("email_id")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("email_id")).getValue()%>' maxlength = '100'></td>
							<% }
							else
							{%>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
								<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
							<% }%>
						</tr>
						<tr>							
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;<b>Blacklisted/<br>&nbsp;&nbsp;Negated Customer</b></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:isblacklist" id="wdesk:isblacklist" value='<%=((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("isblacklist")).getValue()%>' readonly DISABLED=true  maxlength = '100'></td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
						</tr>
						<tr>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
							<td style="text-align:right;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
								<input name='Fetch' type='button' id='Fetch' readonly DISABLED=true value='Search' class='EWButtonRB' style='width:85px' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							</td>
							<td style="text-align:left;" nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;&nbsp;&nbsp;
								<input name='Clear' id='Clear'readonly DISABLED=true type='button' value='Clear'  class='EWButtonRB' style='width:85px' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<input name='GetOLDTL' id='GetOLDTL' readonly DISABLED=true type='button' value='Get Old TL' class='EWButtonRB' style='width:85px' >
							</td>
							<td nowrap='nowrap' class='EWNormalGreenGeneral1'>&nbsp;</td>
						</tr>
					</table>
				</div>
			</div>
			<div id="divCheckbox" style="display: none;">
				<div class="accordion-group">
					<div class="accordion-heading">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel20">List of CIFs
							</a>
						</h4>
					</div>
					<div id="panel20" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table width="100%" border='1' cellspacing='1' cellpadding='0'>
								<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Select</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Number</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>Name</b></td>
									<td style="text-align:center" class="EWNormalGreenGeneral1" colspan="1"><b>CIF Type</b></td>
								</tr>
								<tr width="100%" colspan =4 class="EWHeader" bgcolor= "#990033">
									<td style="text-align:center;" nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="radio" name="individual" value="Individual" id="individual" onclick="javascript:showDivForRadio();"></td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>5003089</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Julius Ceasar</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Individual</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
			
			<div id="divCheckbox2" style="display: none;">
				<div class="accordion-group">
					<div class="accordion-heading" id="div_TradeLicDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel3">Trade License Details</a>
						</h4>
					</div>
					<div id="panel3" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table id="TAB_TradeLicenseDetails" border='1' cellspacing='1' cellpadding='0' width=100%>
								<tr>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'>Company Name</td>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Company_Name" maxlength = '100' id="wdesk:Company_Name" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Company_Name")).getValue()%>'></td>
									<td nowrap='nowrap' width="23%" class='EWNormalGreenGeneral1'>Trade License Number</td>
									<td nowrap='nowrap' width="24%" class='EWNormalGreenGeneral1'><input type="text" name="wdesk:TL_Num" maxlength = '100' id="wdesk:TL_Num"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("TL_Num")).getValue()%>'></td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap'  class='EWNormalGreenGeneral1' height ='22'>Segment</td>
									<td nowrap='nowrap'  class='EWNormalGreenGeneral1' height ='22'><input type="text" name="wdesk:Segment" maxlength = '100' id="wdesk:Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Segment")).getValue()%>'></td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Sub-Segment</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Sub_Segment" maxlength = '100' id="wdesk:Sub_Segment" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Sub_Segment")).getValue()%>'></td>									
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>ID Issued Organisation</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:ID_Issued_Org" maxlength = '100' id="wdesk:ID_Issued_Org" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("ID_Issued_Org")).getValue()%>' >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Issue Date</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Issue_Date" maxlength = '100' id="wdesk:Issue_Date" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Issue_Date")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(Existing)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Exis_Expiry_Date" maxlength = '100' id="wdesk:Exis_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Exis_Expiry_Date")).getValue()%>'  >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Expiry Date(New)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_Expiry_Date" maxlength = '100' id="wdesk:New_Expiry_Date" readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_Expiry_Date")).getValue()%>'  >
										<% if(!"R".equalsIgnoreCase(readOnlyFlag)){%>
										<img style="cursor:pointer" ='/webdesktop/webtop/images/images/cal.gif' onclick = "initialize('wdesk:New_Expiry_Date');" width='16' height='16' border='0' alt='' >
										<%}%>
									</td>
								</tr>
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(Old)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:Old_KYC_Expiry_Date" maxlength = '100' id="wdesk:Old_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Old_KYC_Expiry_Date")).getValue()%>'  >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>KYC Expiry Date(New)</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:New_KYC_Expiry_Date" maxlength = '100' id="wdesk:New_KYC_Expiry_Date"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("New_KYC_Expiry_Date")).getValue()%>'  >
									</td>

									<tr width=100%>
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Legal Entity
										<td nowrap='nowrap' class='EWNormalGreenGeneral1'>
											<select name="wdesk:LegalEntity" id="wdesk:LegalEntity" disabled>
												<option value="">-- Select Legal Entity--</option>
											</select>
											
									<td style="padding-left: 5px;" class="EWNormalGreenGeneral1">Risk Score</td>
                                    <td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:RiskScore" maxlength="100" id="wdesk:RiskScore"   readonly DISABLED=truevalue='<%= (attributeMap.get("RiskScore") != null) ? ((WorkdeskAttribute)attributeMap.get("RiskScore")).getValue() : "" %>'>

									</td>
									
										
							 	 </tr>	 
							 	<tr width=100%>
							 		<td  nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Segment
							 		<td   nowrap='nowrap' class='EWNormalGreenGeneral1'>
							 			<select style = "maxlength='12'" name="wdesk:IndustrySegment" id="wdesk:IndustrySegment" disabled>
							 				<option style= "maxlength='12'" value="">-- Select Industry --</option>
											</select>
										</td>	
										<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Industry Subsegment</td>
										<td   style= "width: 30%;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
											<select  maxlength='12' name="wdesk:IndustrySubsegment" id="wdesk:IndustrySubsegment" disabled>
												<option  maxlength='12' value="">-- Select Industry --</option>
											</select>
										</td>
									</tr
									
									
							
								
								<tr width=100%>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Emirates</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:EmiratesUnifiedLicense" maxlength = '100' id="wdesk:EmiratesUnifiedLicense"  readonly DISABLED=true   value='<%=((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("EmiratesUnifiedLicense")).getValue()%>'  >
									</td>
									<td style="padding-left: 5px;" nowrap='nowrap' class='EWNormalGreenGeneral1'>Unified License Number - Federal</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'><input type="text" name="wdesk:FederalUnifiedLicense" maxlength = '100' id="wdesk:FederalUnifiedLicense"  readonly DISABLED=true value='<%=((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("FederalUnifiedLicense")).getValue()%>'  >
									</td>
								</tr>
								<tr width=100%>		
									<td class='EWNormalGreenGeneral1 width23'>Unified License - Issuing Emirate</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' DISABLED width="23%">
											<select id="Emirates" name="Emirates" style="width: 130px;" onchange="changeVal(this,'wdesk:Emirates')" disabled  >
												<option  value="--Select--" selected >--Select--</option>
												<option  value="Abu Dhabi" selected >Abu Dhabi</option>
												<option  value="Dubai" selected >Dubai</option>
												<option  value="Sharjah" selected >Sharjah</option>
												<option  value="Ajiman" selected >Ajiman</option>
												<option  value="Umm Al Quwain" selected >Umm Al Quwain</option>
												<option  value="Ras Al Khaimah" selected >Ras Al Khaimah</option>
												<option  value="Fujairah" selected >Fujairah</option>
												</option>
											</select>
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' height ='22'>&nbsp;&nbsp;</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				
				<div class="accordion-group" >
					<div class="accordion-heading" id="div_SupportingDocs">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel7">Supporting Documents Required
							</a>
						</h4>
					</div>
					<div id="panel7" class="accordion-body collapse">
						<div class="accordion-inner">
							<table id="TAB_SupportingDocs" border='1' cellspacing='1' cellpadding='0' width="100%" >
								<tr width="100%">
									<td colspan =3 style="text-align:right; width: 45%";" nowrap='nowrap' class='EWNormalGreenGeneral1' style=>							
									<p align="right"><b>List of Possible Documents&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></p>
									<div id='divDocumentList' style="OVERFLOW: auto;WIDTH: 304px;HEIGHT: 147px" onscroll="OnDivScroll(this.id);" >
										<select multiple size="8" id='documentList' name="FromLB" style="width:auto">
											<%
												for(int i=0;i<documentValues.length;i++){
													boolean toAdd=true;
													if(selectedDocumentValues!=null && selectedDocumentValues.length>0)
													{
														//WriteLog("documentValues[i] "+documentValues[i]);
														for(int j=0;j<selectedDocumentValues.length;j++){
															if(selectedDocumentValues[j].equalsIgnoreCase(documentValues[i])) 
															{
																//WriteLog("selectedDocumentValues[j] "+selectedDocumentValues[j]);
																toAdd=false;
																break;
															}		
														}
													}	
													if(!toAdd) continue;
												
												%>
											<option value="<%=documentValues[i]%>"><%=documentValues[i]%></option>
											<%}%>
										</select>
									</div>
									</td>
									<td style="text-align:center; width: 10%;" nowrap='nowrap' class='EWNormalGreenGeneral1' valign="middle"> 
										<input type="button"  id="addButton" class='EWButtonRB' <%=strDisableReadOnly%> style='width:100px' onClick="move(this.form.FromLB,this.form.ToLB,this)" 
											value="Add >>"><br />
										<input type="button" id="removeButton" class='EWButtonRB' <%=strDisableReadOnly%> style='width:100px' onClick="move(this.form.ToLB,this.form.FromLB, this)" 
											value="<< Remove">
									</td>
									<td style="text-align:left; width: 45%;" nowrap='nowrap' class='EWNormalGreenGeneral1'>
										<p><b>List of Selected Documents</b></p>
										<div id='divSelectedList' style="OVERFLOW: auto;WIDTH: 304px;HEIGHT: 147px" onscroll="OnDivScroll(this.id);" >
											<select id="selectedList" multiple size="8" name="ToLB" style="width:auto;">
											</select>
										</div>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<div class="accordion-group">
					<div class="accordion-heading" id="div_DecisionDetails">
						<h4 class="panel-title">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#panel22">Decision Details</a>
						</h4>
					</div>
					<div id="panel22" class="accordion-body collapse in">
						<div class="accordion-inner">
							<table id="TAB_DecisionDetails" border='1' cellspacing='1' cellpadding='0' width=100% >
								<tr>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1'width="23%"><b>Decision</b></td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
										<select id="DecisionDropDown" name="DecisionDropDown"  <%=strDisableReadOnly%>  style="width: 130px;" onchange="changeVal(this,'<%=WSNAME%>')"  >
											<option value="--Select--" selected >--Select--</option>
											<%for(int i=0;i<DecisionCombo.length;i++){
												if(DecisionCombo[i].trim().equalsIgnoreCase("Decision"))%>
											<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
											<%}%>
										</select>
										<input name='decision_history' id='decision_history' type='button' value='Decision History' onclick="HistoryCaller()" class='EWButtonRB' style='width:100px' >
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Reject Reason
									</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
										<input type="hidden" name="wdesk:rejectReason" id="wdesk:rejectReason" value=''>
										<select disabled id="rejectreason" name="rejectreason" onchange="changeVal(this,'<%=WSNAME%>')" <%=strDisableReadOnly%> style="width: 175px;" >
											<option value="--Select--" selected>--Select--</option>
											<%for(int i=0;i<DecisionCombo.length;i++){
												if(DecisionCombo[i].trim().equalsIgnoreCase("Reject Reason"))%>
											<option value="<%=DecisionComboValues[i].trim()%>"><%=DecisionComboValues[i].trim()%></option>
											<%	}%>										
										</select>
									</td>
								</tr>
								<tr>
									<td  nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">Remarks</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="23%">
										<textarea id ="wdesk:Remarks" maxlength="3000" onblur="trimLength(this.id,this.value,3000);" name ="wdesk:Remarks" <%=strDisableReadOnly%> style="width: 100%;"  rows="5" cols="50"></textarea>
									</td>
									<td width="23%" nowrap='nowrap' class='EWNormalGreenGeneral1'>Memopads</td>
									<td nowrap='nowrap' class='EWNormalGreenGeneral1' width="24%">
										<textarea id ="MemoPads" disabled name ="MemoPads" style="width: 100%;"  rows="5" cols="50"><%=((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()%></textarea>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
			<%} %>
			<!---  End Rest all steps  -->
			<input type='hidden' name="temp_wi_name" id="temp_wi_name" value='<%=WINAME%>' />
			<input type='hidden' name="mainGridDataForTable" id="mainGridDataForTable"  />
			<input type='hidden' name="wdesk:WS_NAME" id="wdesk:WS_NAME" value='<%=WSNAME%>'/>
			<input type='hidden' name="wdesk:WI_NAME" id="wdesk:WI_NAME" value='<%=wdmodel.getWorkitem().getProcessInstanceId()%>'/>
			<input type="hidden" id="wdesk:Decision" name="wdesk:Decision" value='<%=((WorkdeskAttribute)attributeMap.get("Decision")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Decision")).getValue()%>'>
			<input type="hidden" id="OPSMakerDecision" value='<%=((WorkdeskAttribute)attributeMap.get("OPSMakerDecision")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("OPSMakerDecision")).getValue()%>'>
			<input type="hidden" id="OPSCheckerDecision" value='<%=((WorkdeskAttribute)attributeMap.get("OPSCheckerDecision")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("OPSCheckerDecision")).getValue()%>'>
			<input type="hidden" id="wdesk:RejectReason" name="wdesk:RejectReason" value='<%=((WorkdeskAttribute)attributeMap.get("rejectreason")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("rejectreason")).getValue()%>'>
			<input type="hidden" name="wdesk:Emirates" id="wdesk:Emirates" value='<%=((WorkdeskAttribute)attributeMap.get("Emirates")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Emirates")).getValue()%>'>
			<input type="hidden" id="wdesk:Share_Holder_Details" name="wdesk:Share_Holder_Details" value='<%=((WorkdeskAttribute)attributeMap.get("Share_Holder_Details")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Share_Holder_Details")).getValue()%>'> 
			<input type="hidden" id="wdesk:Supporting_Docs" name="wdesk:Supporting_Docs" value='<%=((WorkdeskAttribute)attributeMap.get("Supporting_Docs")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Supporting_Docs")).getValue()%>'> 
			<input type="hidden" id="wdesk:MemoPad" name="wdesk:MemoPad" value='<%=((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("MemoPad")).getValue()%>'>
			<input type="hidden" id="Sys_Hold_Decision" value='<%=((WorkdeskAttribute)attributeMap.get("Sys_Hold_Decision")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("Sys_Hold_Decision")).getValue()%>'>
		</form>
		<!--<script language="javascript" src="/webdesktop/webtop/scripts/SRM_Scripts/keyPressValidation.js"></script> -->
		<!--<script language="javascript" src="/webdesktop/webtop/scripts/SRM_Scripts/formLoad_SRM.js?"></script> -->
		<script language="javascript" src="/webdesktop/webtop/scripts/SRM_Scripts/populateCustomValue.js"></script>
		<script language="JavaScript" src="/webdesktop/webtop/scripts/calendar_SRM.js"></script>
		<script language="javascript" src="/webdesktop/webtop/scripts/SRM_Scripts/json3.min.js"></script>
		<script language="javascript" src="/webdesktop/webtop/scripts/client.js"></script>
		<script>
			function initialize_DT(eleId) {					
				var cal1 = new calendarfn2(document.getElementById(eleId));
				cal1.year_scroll = true;
				cal1.time_comp = false;
				cal1.popup();
				return true;
			}
			
			function initialize(eleId) {	
				var cal1 = new calendarfn(document.getElementById(eleId));
				cal1.year_scroll = true;
				cal1.time_comp = false;
				cal1.popup();	
				return true;
			}
			
			function formatDate(input)
			{
				if(input == "")
				return "";
				else if(input!=null)
				{
				var datePart = input.match(/\d+/g),
				year = datePart[0].substring(0),
				month = datePart[1],day = datePart[2];
				}
				
				return day+'/'+month+'/'+year;
			}
			function trimLength(id,value,maxLength){
				newLength=value.length;
				value=value.replace(/(\r\n|\n|\r)/gm," ");
				//alert(value);
				value=value.replace(/[^a-zA-Z0-9_.,&: ]/g,"");
				//alert(value);
			
				if(newLength>=maxLength){
					value=value.substring(0,maxLength);
				}
				document.getElementById(id).value=value.trim();
			}
			function loadDropdownvalues(fieldType) {
				if(fieldType=='IndustrySegment'){
					var industrySegmentDropdown = document.getElementById("wdesk:IndustrySegment");
					var industrySegmentDropdownValue ="<%=((WorkdeskAttribute)attributeMap.get("IndustrySegment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("IndustrySegment")).getValue()%>";
					// Fetch values directly from JSP
					var returnValues = "<%= returnValuesStr.replace("\"", "\\\"") %>";
					var values = returnValues.split("~");
					industrySegmentDropdown.innerHTML = '<option value="">-- Select Industry Segment --</option>';
					for (var j = 0; j < values.length; j++) {
						var row = values[j].split("|"); 
						if (row.length === 2) {
							var opt = document.createElement("option");
							opt.value = row[0]; // Save segment code in backend
							opt.text = row[1];  // Show segment description in dropdown
							if (row[0] === industrySegmentDropdownValue) {
								opt.selected = true;
							}
							industrySegmentDropdown.options.add(opt);
						}
					}
				}
				if(fieldType=='IndustrySubsegment'){
					var industrySubsegmentDropdown = document.getElementById("wdesk:IndustrySubsegment");
					var industrySubsegmentDropdownValue ="<%=((WorkdeskAttribute)attributeMap.get("IndustrySubsegment")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("IndustrySubsegment")).getValue()%>";
					// Fetch values directly from JSP
					var returnValues2 = "<%= returnValuesStr2.replace("\"", "\\\"") %>";
					var values = returnValues2.split("~");
					industrySubsegmentDropdown.innerHTML = '<option value="">-- Select Industry Subsegment --</option>';
					for (var j = 0; j < values.length; j++) {
						var row = values[j].split("|"); 
						if (row.length === 2) {
							var opt = document.createElement("option");
							opt.value = row[0]; // Save segment code in backend
							opt.text = row[1];  // Show segment description in dropdown
							if (row[0] === industrySubsegmentDropdownValue) {
								opt.selected = true;
							}
							industrySubsegmentDropdown.options.add(opt);
						}
					}
				}
				if(fieldType=='LegalEntity'){
					var LegalEntityDropdown = document.getElementById("wdesk:LegalEntity");
					var LegalEntityDropdownValue ="<%=((WorkdeskAttribute)attributeMap.get("LegalEntity")).getValue()==null?"":((WorkdeskAttribute)attributeMap.get("LegalEntity")).getValue()%>";
					// Fetch values directly from JSP
					var returnValues3 = "<%= returnValuesStr3.replace("\"", "\\\"") %>";
					var values = returnValues3.split("~");
					LegalEntityDropdown.innerHTML = '<option value="">-- Select Legal Entity --</option>';
					for (var j = 0; j < values.length; j++) {
						var row = values[j].split("|"); 
						if (row.length === 2) {
							var opt = document.createElement("option");
							opt.value = row[0]; // Save segment code in backend
							opt.text = row[1];  // Show segment description in dropdown
							if (row[0] === LegalEntityDropdownValue) {
								opt.selected = true;
							}
							LegalEntityDropdown.options.add(opt);
						}
					}
				}
				if(fieldType=='Emirates'){
					var dropDownArray=['Emirates'];
					var textBoxArray=['wdesk:Emirates'];
					for(var i=0;i<dropDownArray.length;i++)
					{
						var textBoxValue=document.getElementById(textBoxArray[i]).value;
						if(textBoxValue!='')
							document.getElementById(dropDownArray[i]).value=textBoxValue;
					}
				}
			
			}
		</script>
	</body>
</html>