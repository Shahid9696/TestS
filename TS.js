var TS_onLoad = document.createElement('script');
TS_onLoad.src = '/TS/TS/CustomJS/TS_onLoad.js';
document.head.appendChild(TS_onLoad);
	
var TS_mandatory = document.createElement('script');
TS_mandatory.src = '/TS/TS/CustomJS/TS_MandatoryFieldValidations.js';
document.head.appendChild(TS_mandatory);

	
var TS_onSaveDone = document.createElement('script');
TS_onSaveDone.src = '/TS/TS/CustomJS/TS_onSaveDone.js';
document.head.appendChild(TS_onSaveDone);

var TS_Common = document.createElement('script');
TS_Common.src = '/TS/TS/CustomJS/TS_Common.js';
document.head.appendChild(TS_Common);


var TS_EventHandler = document.createElement('script');
TS_EventHandler.src = '/TS/TS/CustomJS/TS_EventHandler.js';
document.head.appendChild(TS_EventHandler);


function setCommonVariables()
{
	Processname = getWorkItemData("ProcessName");
	ActivityName =getWorkItemData("ActivityName");
	WorkitemNo =getWorkItemData("processinstanceid");
	cabName =getWorkItemData("cabinetname");
	user= getWorkItemData("username");
	setValue("LOGIN_USER",user);
	//alert("user--"+user);
	viewMode=window.parent.wiViewMode;	
}

function afterFormload()
{	
	var formload = executeServerEvent("", "formload", '', true);
	setStyle("REJECT_REASON","visible","false");
	setStyle("OTHER_REJ_REASON","visible","false");
    setCommonVariables();
	fromDateToDate();
	setStyle("add_Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","true");
	//rowCountSettle();
	//disputeReasonButton();
	//typeofblock();
	if(ActivityName=="Document_Attach_Hold" || ActivityName=="Final_Credit")
	{
		setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","true");
	}
	if((ActivityName=="Card_Dispute_Maker" || ActivityName=="Card_Dispute_Checker") || (ActivityName=="TC_Update"))
	{
		setStyle("add_Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","true");
		setStyle("delete_Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","false");
		setStyle("select_Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","true");
	}
	

}
function customValidationsBeforeSaveDone(op)
{	
	if(op=="S")
	{
		return true;
	}
	else if (op=="I" || op=="D")
	{
		if(mandatoryFieldValidation(ActivityName)==false)
		{
			return false;
		}
		
		var confirmDoneResponse = confirm("You are about to submit the workitem. Do you wish to continue?");
		
		if(confirmDoneResponse ==  true)
		{	
			var res = executeServerEvent("InsertIntoHistory", "onDone", '', true);
			setCustomControlsValue();
			var status = insertIntoHistoryTable();
			saveWorkItem();
			var mailStatus="";
			mailStatus=insertIntoMailHistory();
			if(ActivityName=="Card_Dispute_Checker")
			{
				clearTransGridFlag();
				route_TC_Update();
			}
			
			saveWorkItem();
			return true;
		}
		else
		{
			return false;
		}
	}
	return true;
}
function eventDispatched(controlObj,eventObj)
{
	var controlId=controlObj.id;
	var controlEvent=eventObj.type;
	var ControlIdandEvent = controlId+'_'+controlEvent;
	
	switch(ControlIdandEvent)
	{
		case 'SROBTN_click':			
			SRORaise();
			saveWorkItem();
			break;
		case 'CSC_MOB_CONFIRMED_FLAG_0_change':
			var mobConfirmed=executeServerEvent("CSC_MOB_CONFIRMED_FLAG_0","CHANGE",'',true).trim();
			break;
		case 'Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DISPUTE_REASON_change':
			var disputeReason=executeServerEvent("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DISPUTE_REASON","CHANGE",'',true).trim();
			break;
		case 'AD_RELATEDTO_change':
			var relatedTo=executeServerEvent("AD_RELATEDTO","CHANGE",'',true).trim();
			break;
			
		case 'CSC_MOB_CONFIRMED_FLAG_1_change':
			var mobConfirmed=executeServerEvent("CSC_MOB_CONFIRMED_FLAG_1","CHANGE",'',true).trim();
			break;
		case "CustomerSearch_click": //Customer Search
		
			
			if(getValue("SERVICE_TYPE")!="ATM Dispute" && getValue("HEADER_CARD_NO") == "") 
			{
				showMessage("HEADER_CARD_NO","Please Enter CARD NO","error");
				break;
			}
			
			else if(getValue("SERVICE_TYPE")=="Card Dispute"){
				//From_date_to_date();
				var Scheme_Type_Value=executeServerEvent("Scheme_Type_Value","CHANGE",'',true).trim();
				if(Scheme_Type_Value=="error"){
					showMessage("","Please enter valid card number","error");
					setValue("CardSchemeType","");
					setValue("CUSTOMER_NAME","");
					setValue("MOBILE_NO","");
					setValue("EMAIL_ID","");
					setValue("CUSTOMER_TYPE","");
					setValue("CIF_ID","");
					setValue("CARD_CRN_NO","");
					setValue("EXPIRY_DATE","");
					setValue("ELITE_CUST_NO","");
					setValue("SOURCE_ID","");
					setValue("EXT_NO","");
					setValue("GENERAL_STATUS","");
					
					break;
				}else{
					
				}
					
			}
			else if(getValue("SERVICE_TYPE")=="ATM Dispute" && getValue("MODE_OF_SEARCH") == "")
			{
				showMessage("HEADER_CIF","Please Enter Account Number or Card No to perform Customer Search","error");
				break;
			}
			else if(getValue("MODE_OF_SEARCH") == "Card" && getValue("HEADER_CARD_NO") == "" )
			{
				showMessage("HEADER_CARD_NO","Please Enter CARD NO","error");
				break;
			}
			else if(getValue("MODE_OF_SEARCH") == "Account" && getValue("HEADER_CIF") == "" )
			{
				showMessage("HEADER_CIF","Please Enter Account number","error");
				break;
			}
			//var cifIdOnForm = document.getElementById("HEADER_CIF").value;
			//var CardNo = document.getElementById("HEADER_CARD_NO").value;
			if(getValue("HEADER_CIF")!='')
			{
				data=getValue("HEADER_CIF")
			}
			else
			{
				data=getValue("HEADER_CARD_NO")
			}
			var searchResult = executeServerEvent("CustomerSearch", "Click",data, true);
			if(searchResult == 'Integration call successfull')
			{
					
				showAlertDialog('Searching Complete!!');
				saveWorkItem();
					
			}
			else
			{
				showAlertDialog('Searching Failed!!');
				setValue("CardSchemeType","");
				setValue("CUSTOMER_NAME","");
				setValue("MOBILE_NO","");
				setValue("EMAIL_ID","");
				setValue("CUSTOMER_TYPE","");
				setValue("CIF_ID","");
				setValue("CARD_CRN_NO","");
				setValue("EXPIRY_DATE","");
				setValue("ELITE_CUST_NO","");
				setValue("SOURCE_ID","");
				setValue("EXT_NO","");
				setValue("GENERAL_STATUS","");
				saveWorkItem();
			}
			break;
			
		case 'Decision_change' :
				//onChangeDecision(ActivityName);
				enableDisableRejectReasons();
				//DisableMandatoryfield(); //changes made by suraj-20102021
				break;	
				
		case 'SERVICE_TYPE_change' : 
			var serviceType=executeServerEvent("SERVICE_TYPE","CHANGE",'',true).trim();
			break;
					
		case 'CSC_REQUEST_TYPE_change' :
			var cscRequestType=executeServerEvent("CSC_REQUEST_TYPE","CHANGE",'',true).trim();
			disableReversalType('Credit Shield Cancellation');
			break;
			
		case 'CSI_ELIGIBILITY_CC_FLAG_change' :
			var cscRequestType=executeServerEvent("CSI_ELIGIBILITY_CC_FLAG","CHANGE",'',true).trim();
			break;
			
		case 'CSI_ELIGIBILITY_LOAN_FLAG_change' :
			var cscRequestType=executeServerEvent("CSI_ELIGIBILITY_LOAN_FLAG","CHANGE",'',true).trim();
			break;
			
		case 'RP_REQUEST_TYPE_change' :
			var RPRequestType=executeServerEvent("RP_REQUEST_TYPE","CHANGE",'',true).trim();
			break;
		
		case 'AD_TIME_change':
			var result=timeStampValidator(getValue("AD_TIME"));
			if(!result)
			{
				//showMessage("AD_TIME",'Please enter valid time',"error");
				showMessage("AD_TIME",'Please enter valid time in HH:MM:SS format',"error");
			}
			break;
		case 'CSI_TYPEOFCLAIM_change' :
			var typeOfClaim=executeServerEvent("CSI_TYPEOFCLAIM","CHANGE",'',true).trim();
			break;
		case 'AD_LOCATION_change' :
			var atmLoc=executeServerEvent("AD_LOCATION","CHANGE",'',true).trim();
			break;
		case 'CARD_TYPE_change' :
			var cardType=executeServerEvent("CARD_TYPE","CHANGE",'',true).trim();
			break;
		case 'REJECT_REASON_change' :
			if(getValue("REJECT_REASON")=="Others")
			{
				setStyle("OTHER_REJ_REASON","visible","true");
				setStyle("OTHER_REJ_REASON","mandatory","true");
			}
			else
			{
				setValue("OTHER_REJ_REASON","");
				setStyle("OTHER_REJ_REASON","visible","false");
				setStyle("OTHER_REJ_REASON","mandatory","false");
			}
			break;
			
		case 'CSC_NON_CONTACTABLE_BTN_click' :
			stage="Initiation Non-Contactable";
			if(getValue("CSC_REQUEST_TYPE")=="Cancellation")
			{
				subprocess="Cancellation";
			}
			else if(getValue("CSC_REQUEST_TYPE")=="Reversal" || (getValue("CSC_REQUEST_TYPE")=="Cancellation with Reversal") || (getValue("CSC_REQUEST_TYPE")=="Cancellation with Reversal and Other Charges"))
			{
				subprocess="Cancellation with Reversal/Reversal";
			}
			var data=subprocess+"~"+stage;
			var MailhistoryTableInsert=executeServerEvent("InsertMailTrigger","INTRODUCEDONE",data,true).trim();
			break;
			
		case 'RP_NON_CONTACTABLE_BTN_click' :
			stage="Initiation Non-Contactable";
			if(getValue("RP_REQUEST_TYPE")=="Cancellation")
			{
				subprocess="Cancellation";
			}
			else if(getValue("RP_REQUEST_TYPE")=="Reversal" || (getValue("RP_REQUEST_TYPE")=="Cancellation with Reversal"))
			{
				subprocess="Cancellation with Reversal/Reversal";
			}
			var data=subprocess+"~"+stage;
			var MailhistoryTableInsert=executeServerEvent("InsertMailTrigger","INTRODUCEDONE",data,true).trim();
			break;
		case 'Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECISION_change' :
			var dec= getValue("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECISION");
			setValue("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_MODIFIED_AT",getValue("CD_ROUTED_FROM"));
			if(dec=="Decline")
			{
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","visible","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","mandatory","true");
			}
			else 
			{
				setValue("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","mandatory","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","visible","false");
				setValue("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","mandatory","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","visible","false");
			}
			break;
			
		case 'Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON_change' :
			var reason= getValue("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON");
			if(reason=="Others")
			{
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","visible","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","mandatory","true");
			}
			else 
			{
				setValue("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","mandatory","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","visible","false");
				
			}
			break;
		case 'MODE_OF_SEARCH_0_change':
			var searchMode=executeServerEvent("MODE_OF_SEARCH","CHANGE",'',true).trim();
			break;
		case 'MODE_OF_SEARCH_1_change':
			var searchMode=executeServerEvent("MODE_OF_SEARCH","CHANGE",'',true).trim();
			break;
		case 'Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_CATEGORY_change':
			var searchMode=executeServerEvent("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_CATEGORY","CHANGE",'',true).trim();
			break;
			
		//case 'settled_unsettled_add_button_click' :
		//	
		//	 rowCountSettled();
		//	saveWorkItem();
		//	break;
		case 'Manual_ck_change' :
		
			if(getValue("Manual_ck")==true){
				
				var result_Settled = getGridRowCount("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1");
				if(result_Settled > 0){
					var confirmResponse1 = confirm("Grid data will be lost. Do you want to proceed further?");
					if(confirmResponse1 == false){
						setValue("Manual_ck","");
						return false;
					}
					else{
						setStyle("add_Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","false");
						clearTable("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1",true);
			        }
				}
				
				else{
						setStyle("add_Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","false");
						clearTable("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1",true);
			        }
				}
			else if(getValue("Manual_ck")==false){
				var result_Settled = getGridRowCount("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1");
				if(result_Settled > 0){
					var confirmResponse1 = confirm("Grid data will be lost. Do you want to proceed further?");
					if(confirmResponse1 == false){
						setValue("Manual_ck","true");
						return false;
					}
					else{
						setStyle("add_Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","true");
						clearTable("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1",true);
			        }
				}
				else{
				setStyle("add_Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","true");
				clearTable("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1",true);
			        }
				}
            break;
			
		case 'MAX_NOF_TRANSACTIONS_change':
			
			saveWorkItem();
		break;
		
		case 'DISPUTE_REASON_change':
			var dispute_exec=executeServerEvent("DISPUTE_REASON","CHANGE",'',true).trim();
			//saveWorkItem();
		break;

		case 'TYPE_OF_BLOCK_change':
			var dispute_exec=executeServerEvent("TYPE_OF_BLOCK","CHANGE",'',true).trim();
			//saveWorkItem();
		break;
		
		case 'Card_Block_click':
		if(getValue("BLOCK_REASON_CODE")!="")
			{                                  
         var cardblockStatus =executeServerEvent("CardblockStatus","CHANGE",'',true);
         var Card_status = getValue("GENERAL_STATUS");
         if(cardblockStatus == 'Card in Permanent block status'){
                         showMessage('',"Card in Permanent block status cannot be changed to Temporary.","error");
                         return false;
         }else if(cardblockStatus == 'Card cannot be blocked'){
                         showMessage('',"Card cannot be blocked, Card Status - "+ Card_status,"error");
                         return false;
         }else if(cardblockStatus == 'Card cannot be blocked as Temporary'){
                         showMessage('',"Card cannot be blocked as Temporary, Card Status - "+ Card_status,"error");
                         return false;
         }
         else if(cardblockStatus == 'Card cannot be blocked as Permanent'){
                         showMessage('',"Card cannot be blocked as Permanent, Card Status - "+ Card_status,"error");
                         return false;
         }
         else if(cardblockStatus == 'Successfull'){
                         
                         var Card_Maintainance =executeServerEvent("Card_Maintainance","Click",'',true);
                         if(Card_Maintainance == 'Integration call successfull')
                         {
                                                         
                                         showMessage("Card_Block",'Card has been successfully blocked',"error");
                                         saveWorkItem();
                                                         
                         }
                         else
                         {
                                         showMessage("Card_Block",'Card blocked failed',"error");
                         }
         }
			}
		else{
			showMessage("Card_Block",'Please select block reason',"error");
		}

		break;
						
			
		default:
			break;
	}
}
function pausecomp(millis)
{
    var date = new Date();
    var curDate = null;
    do { curDate = new Date(); }
    while(curDate-date < millis);
}

function customListViewValidation(tableId,flag)
{
	if(tableId == "REJECT_REASON_GRID")
	{		
		var reasonVal = getSelectedItemLabel("table26_Reject Reason");
		if(reasonVal=="Select")
		{
			showMessage(tableId,'Please Choose Valid Reject Reason',"error");
			return false;
		}

	}
	return true;
}

function onTableCellChange(rowIndex,colIndex,ref,controlId)
{	
}


function OnRowClickofListview(controlId,flag)
{
	if(controlId=='Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1')
	{
		if((ActivityName=="Initiation" || ActivityName=="Branch_Return"))
		{
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TEMP_CC_ASSIGN","visible","false");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECISION","visible","false");
		}
		else if((ActivityName=="Card_Dispute_Maker" || ActivityName=="Card_Dispute_Checker"))
		{
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TRANS_DATE","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AMT_IN_FC","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AMT_IN_AED","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_MERCHANT_NAME","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AUD_ID","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DISPUTE_REASON","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TEMP_CC_ASSIGN","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECISION","mandatory","true");
			var category=getValue("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_CATEGORY");
			if(ActivityName=="Card_Dispute_Maker" && category=="Secured"){
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TYPES_SRCURED_TRANS","mandatory","true");
				
			}
			
		}
		else if((ActivityName=="TC_Update"))
		{
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TRANS_DATE","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AMT_IN_FC","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AMT_IN_AED","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_MERCHANT_NAME","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AUD_ID","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DISPUTE_REASON","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECISION","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","disable","false");
			
			
			
			
		}
		if ((ActivityName!="Card_Dispute_Maker") && (ActivityName!="Initiation")){
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_CATEGORY","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TYPES_SRCURED_TRANS","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_LOCATION","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_SERNO","disable","true");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_ARN","disable","true");
			
		}
		
		if(flag == "M")
		{
			var dec= getValue("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECISION");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_MODIFIED_AT","visible","false");
			if(dec=="Decline")
			{
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TEMP_CC_ASSIGN","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","visible","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","mandatory","true");
			}
			else 
			{
				
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","mandatory","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","visible","false");
			}
			
			var reason= getValue("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON");
			if(reason=="Others")
			{
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","visible","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","mandatory","true");
				
			}
			else 
			{
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","mandatory","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","visible","false");
				
			}
			if(getValue("Manual_ck")==true)
			{
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TRANS_DATE","disable","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AMT_IN_FC","disable","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AMT_IN_AED","disable","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_MERCHANT_NAME","disable","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AUD_ID","disable","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DISPUTE_REASON","disable","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_CATEGORY","disable","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TYPES_SRCURED_TRANS","disable","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_LOCATION","disable","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_SERNO","disable","false");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_ARN","disable","false");
				setStyle("savechanges_Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","false");
			}
			else if(getValue("Manual_ck")==false)
			{
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TRANS_DATE","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AMT_IN_FC","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AMT_IN_AED","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_MERCHANT_NAME","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_AUD_ID","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DISPUTE_REASON","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_CATEGORY","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_TYPES_SRCURED_TRANS","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_LOCATION","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_SERNO","disable","true");
				setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_ARN","disable","true");
				setStyle("savechanges_Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","disable","true");
			}
			
		}
		if(flag == "A")
		{
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_DECLINE_REASON","visible","false");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_OTH_DECLINE_REASON","visible","false");
			setStyle("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS_MODIFIED_AT","visible","false");
		}
		
	}
}
function addRowPostHook(tableId)
{	
	if(tableId=="Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1")
	{		
		var CDGrid_Size=getGridRowCount('Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1');
		
		var ref_no=executeServerEvent("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1","INTRODUCEDONE",CDGrid_Size,true);
	}
}
function timeStampValidator(timeStamp)
{
	//var pattern=/[0-2][0-3]:[0-5][0-9]:[0-5][0-9]/;
	var pattern=/([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]/;
	//var pattern=/^(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d)$/;
	return pattern.test(timeStamp);
}
function DisputeReasonCheck()
{
	var size=getGridRowCount("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1");
	var j=0;
	for(i=0;i<size;i++)
	{
		var reason=getValueFromTableCell("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1",i,6);
		if(reason=="Fraud")
		{
			j=j+1;
		}
	}
	if(j==size)
	{
		setControlValue("CARD_DISPUTE_TYPE","FRAUD");
		return true;
	}
	else if(j==0)
	{
		setControlValue("CARD_DISPUTE_TYPE","SRVC");
		return true;
	}
	else
	{
		return false;
	}
}
function clearTransGridFlag()
{
	var size=getGridRowCount("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1");
	for(i=0;i<size;i++)
	{
		setTableCellData("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1",i,11,"",true);
	}
}

function route_TC_Update(){
	
		var rowCounttrans = getGridRowCount("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1");
		var flag_appr =false;
		var flag_dec =false;
		
		
		for(var i =0; i<rowCounttrans; i++){
			var Trans_decision = getValueFromTableCell("Q_NG_TS_TRANS_DISPUTE_GRID_DTLS1",i,7);
			if(Trans_decision == "Approve"){
				flag_appr =true;
				break;
			} else if(Trans_decision == "Decline"){
				flag_dec =true;
				
			}
		}
		if(flag_appr){
			setControlValue("Route_For_Tc_Update","Y");
		} else if(flag_dec){
			setControlValue("Route_For_Tc_Update","N");
		}
		
}

function getCurrentDateDDMMYYYY() {
  const today = new Date();
  const day = String(today.getDate()).padStart(2, '0');
  const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
  const year = today.getFullYear();
  return `${day}/${month}/${year}`;
}

function getPastDate120DaysDDMMYYYY() {
   const pastDate = new Date();
   pastDate.setDate(pastDate.getDate() - 120);
   const day = String(pastDate.getDate()).padStart(2, '0');
   const month = String(pastDate.getMonth() + 1).padStart(2, '0');
   const year = pastDate.getFullYear();
   return `${day}/${month}/${year}`;
 }

function fromDateToDate() {
var mindate=getPastDate120DaysDDMMYYYY();
var maxdate=getCurrentDateDDMMYYYY();
setDateRange("TRANSACTION_SEARCH_FROM_DATE",mindate,maxdate);     
setDateRange("TRANSACTION_SEARCH_TO_DATE",mindate,maxdate);  
}

function parseDate(input){
		const parts = input.split('/');
		return new Date(parts[2], parts[1] -1,parts[0]);
	}


function subFormValidation() {
	var fromDateF = getValue("TRANSACTION_SEARCH_FROM_DATE");
			var todateF = getValue("TRANSACTION_SEARCH_TO_DATE");
			const fromDate = parseDate(fromDateF);
	        const todate = parseDate(todateF);
			
			if(getValue("TRANSACTION_SEARCH_FROM_DATE") == "" && getValue("TRANSACTION_SEARCH_TO_DATE") == "")
			{
				showMessage("","Please select from date and to date","error");
				return false;
				
			}
			else if(getValue("TRANSACTION_SEARCH_FROM_DATE") == "")
			{
				showMessage("","Please select from date","error");
				return false;
			
			}
			else if(getValue("TRANSACTION_SEARCH_TO_DATE") == "")
			{
				showMessage("","Please select to date","error");
				return false;
				
			}
			
			else if(getValue("TRANSACTION_SEARCH_FROM_DATE") !== "" && getValue("TRANSACTION_SEARCH_TO_DATE") !== "")
			{
				
				if(fromDate>todate)
				{
					showMessage("","From date should be less then to date","error");
					setValue("TRANSACTION_SEARCH_FROM_DATE","");
					setValue("TRANSACTION_SEARCH_TO_DATE","");
					return false;
					
				}
			}
	
}
//for search button in transection search in card dispute section click DISPUTE_REASON,testcustomID


function subFormPreHook(button5)
{ 
	var testvar=subFormValidation();
	
		if(testvar==false){
                                
            return false;
        }
        else {
			console.log("inside 1 elese condit");
            
            return true;
                                
        }
}



function subFormLoad(button5){
	console.log("inside subFormLoad");
	var result_Settled = getGridRowCount("Q_NG_TS_SETTLED_TRANSACTION_GRID_DTLS");
	var result_UNSettled = getGridRowCount("Q_NG_TS_UNSETTLED_TRANSACTION_GRID_DTLS");
	clearTable("Q_NG_TS_SETTLED_TRANSACTION_GRID_DTLS",true);
	clearTable("Q_NG_TS_UNSETTLED_TRANSACTION_GRID_DTLS",true);
			/*if(result_Settled>0){
				console.log("inside if 1 condit"); 
				clearTable("Q_NG_TS_SETTLED_TRANSACTION_GRID_DTLS",true);
				
			
			}if(result_UNSettled>0){
				console.log("inside if 2 condit");
				clearTable("Q_NG_TS_UNSETTLED_TRANSACTION_GRID_DTLS",true);
				
			}*/
	var button_exec=executeServerEvent("CardDisputeSearch","Click",'',true);
            
                                                
}

//function rowCount(){
//	var rowcountsettled = getSelectedRowsDataFromTable('Q_NG_TS_SETTLED_TRANSACTION_GRID_DTLS');
//	var rowcountUnsettled = getSelectedRowsDataFromTable('Q_NG_TS_UNSETTLED_TRANSACTION_GRID_DTLS');
//	console.log(rowcountsettled);
//console.log(rowcountUnsettled);	
//}

/*function rowCountSettled(){
	var selRowInd_settled = getSelectedRowsIndexes("Q_NG_TS_SETTLED_TRANSACTION_GRID_DTLS");
	var selRowInd_Unsettled = getSelectedRowsIndexes("Q_NG_TS_UNSETTLED_TRANSACTION_GRID_DTLS");
				var settledTrs_exec ="";
				var UnsettledTrs_exec= "";
				var digits_settled = [];
				var digits_Unsettled = [];
				if(selRowInd_settled == "" && selRowInd_Unsettled == ""){
					showMessage("","No Record Selected","error");
				}
				if(selRowInd_settled !==""){
			
				//to unchecked the selected rows after operation
					for(var k=0;k<selRowInd_settled.length;k++){
					var numString_settled = selRowInd_settled[k].toString();
					digits_settled.push(parseInt(numString_settled));	
					};
					for(var j=0; j<digits_settled.length;j++){
						setTableCellData("Q_NG_TS_SETTLED_TRANSACTION_GRID_DTLS",digits_settled[j],15,"Y",true);
						//document.getElementById("NG_COURTORDER_GR_INDIVIDUAL_PRODUCT_DETAILS"+"_"+digits[j]).checked = false; //to unchecked the selected rows after operation
					}
					settledTrs_exec=executeServerEvent("SETTLED_TRANSACTION_GRID_DTLS","CHANGE",'',true);
				}
				if(selRowInd_Unsettled !==""){
			
				//to unchecked the selected rows after operation
					for(var k=0;k<selRowInd_Unsettled.length;k++){
					var numString_Unsettled = selRowInd_Unsettled[k].toString();
					digits_Unsettled.push(parseInt(numString_Unsettled));	
					};
					for(var j=0; j<digits_Unsettled.length;j++){
						setTableCellData("Q_NG_TS_UNSETTLED_TRANSACTION_GRID_DTLS",digits_Unsettled[j],15,"Y",true);
						//document.getElementById("NG_COURTORDER_GR_INDIVIDUAL_PRODUCT_DETAILS"+"_"+digits[j]).checked = false; //to unchecked the selected rows after operation
					}
					UnsettledTrs_exec=executeServerEvent("UnSETTLED_TRANSACTION_GRID_DTLS","CHANGE",'',true);
				}if(settledTrs_exec =="Successfull_SETTLED_TRANSACTION" || UnsettledTrs_exec == "Successfull_UnSETTLED_TRANSACTION"){
					
					showMessage("","Record enter successfull","error");
					
				}
					
				
}
*/

function rowCountSettle(){
	var selRowInd_settled = getSelectedRowsIndexes("Q_NG_TS_SETTLED_TRANSACTION_GRID_DTLS");
	var selRowInd_Unsettled = getSelectedRowsIndexes("Q_NG_TS_UNSETTLED_TRANSACTION_GRID_DTLS");
	var totalrowcount = selRowInd_settled.length + selRowInd_Unsettled.length;
	if(totalrowcount <35){
		if(selRowInd_settled !==""){
		
		var table_settled = document.getElementById("Q_NG_TS_SETTLED_TRANSACTION_GRID_DTLS");
	var settledTrs_exec ="";
	console.log(table_settled);
	var allrows_settled = table_settled.rows;
	
	var headerRow_settled = table_settled.rows[0];
	var columnName_settled =[];
	for(let i =0; i<headerRow_settled.cells.length; i++){
		var th = headerRow_settled.cells[i];
		var label =th.getAttribute("aria-label")?.trim();
		columnName_settled.push(label || `column${i + 1}`);

	}
	let finalOutput ='';
	for(let i =0; i<selRowInd_settled.length; i++){
		var actualindex_settled= selRowInd_settled[i]+1;
		var row_settled= allrows_settled[actualindex_settled];
		if(!row_settled) continue;
		
		let rowText ='';
		for(let j =1; j<columnName_settled.length; j++){
			var cell =row_settled.cells[j];
			var value =cell?.innerText.trim() || '';
			rowText+= `[${columnName_settled[j]}, ${value}]`;
			if(j < columnName_settled.length -1) rowText+=',';			
		}
		finalOutput +=rowText;
		if(i < selRowInd_settled.length -1) finalOutput+= '|';
	}
	settledTrs_exec=executeServerEvent("SETTLED_TRANSACTION_GRID_DTLS","CHANGE",finalOutput,true);
	}
	if(selRowInd_Unsettled !==""){
		
	var table_Unsettled = document.getElementById("Q_NG_TS_UNSETTLED_TRANSACTION_GRID_DTLS");
	var UnsettledTrs_exec ="";
	console.log(table_Unsettled);
	var allrows_Unsettled = table_Unsettled.rows;
	
	var headerRow_Unsettled = table_Unsettled.rows[0];
	var columnName_Unsettled =[];
	for(let i =0; i<headerRow_Unsettled.cells.length; i++){
		var th = headerRow_Unsettled.cells[i];
		var label =th.getAttribute("aria-label")?.trim();
		columnName_Unsettled.push(label || `column${i + 1}`);

	}
	let finalOutput ='';
	for(let i =0; i<selRowInd_Unsettled.length; i++){
		var actualindex_Unsettled= selRowInd_Unsettled[i]+1;
		var row_Unsettled= allrows_Unsettled[actualindex_Unsettled];
		if(!row_Unsettled) continue;
		
		let rowText ='';
		for(let j =1; j<columnName_Unsettled.length; j++){
			var cell =row_Unsettled.cells[j];
			var value =cell?.innerText.trim() || '';
			rowText+= `[${columnName_Unsettled[j]}, ${value}]`;
			if(j < columnName_Unsettled.length -1) rowText+=',';			
		}
		finalOutput +=rowText;
		if(i < selRowInd_Unsettled.length -1) finalOutput+= '|';
	}
	UnsettledTrs_exec=executeServerEvent("UnSETTLED_TRANSACTION_GRID_DTLS","CHANGE",finalOutput,true);
	}
	}
	else{
		
		var confirmDoneResponse = confirm("Kindly select only 35 records");
		return false;
	}
	
	
	
	
}
function subformDoneClick(button5){
	rowCountSettle();
	//refreshFrame("cardDispute");
	//rowCount();
}