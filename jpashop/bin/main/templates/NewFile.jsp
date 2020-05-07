<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
	/*******************************************************************************
	 * 시스템명	: 주차통합관리시스템(NPMU)
	 * 업무명	  : 공통기능
	 * 프로그램명  : parkMapList.jsp
	 * AUTHOR	  : jaqp7363
	 * DESCRIPTION : 주차장 지도 리스트
	 *
	 * 수정내역	:
	 * 수정자	   수정일자		   수정내역
	 * ------  -------------  ----------------------------
	 * jaqp7363	 2019-10-02	  최초생성
	 *
	 ********************************************************************************/
%>
<!doctype html>
<html lang="ko">
<head>
<%@include file="/WEB-INF/jsp/npms/npmm/include/top.jsp"%>
<style type="text/css">
caption {
	position: unset; width: unset; height: unset; padding: 5px; overflow: unset; font-size: unset; font-weight: bold; line-height: unset; visibility: unset; z-index: unset;
}
html, body {
	height : 100%;
	width:100%; 
}
.mapHeader {
	width:100%; height: 60px;
	background-color: white;
	
}
.mapFooter {
	bottom : 0; width:100%; height: 0px;
}
.center {width:100%;text-align:center;}

.tbl tr th {font-size:1rem;line-height:1rem;border-left:2px solid #cfcfcf; color:#333; text-align:center; border-top:2px solid #cfcfcf; background-color:#f6f6f6;}
.tbl tr td {font-size:1rem;line-height:1rem;overflow:hidden; position:relative; border-left:2px solid #cfcfcf; border-top:2px solid #cfcfcf; color:#333;}

.markerBtn {margin-top:4px;}

.conditionBtn {
	width:45%; height:100%; margin: 2px 2px 2px 2px; border:1px solid #c0c0c0; background-color:#fff !important; font-size:1.3rem; color:#606060; line-height:27px;
}
.conditionSelect {
	position:relative; width:100%; padding: 0 4rem 0 1.25rem;
	border:2px solid #cfcfcf; background:url(/resources/images/npmm/ico-select.png) no-repeat right center #fff;
	background-size:2.3rem auto; color:#606060; line-height:1.55rem;font-size:1.1rem;
	-webkit-appearance:none;
}
.tbl tr td select {
	position: relative; display: block; width: 70%; height: 2rem; padding: 0 4rem 0 1.25rem; border: 2px solid #cfcfcf;
	background: url(/resources/images/npmm/ico-select.png) no-repeat right center #fff; -moz-appearance: none;
	background-size: 2.75rem auto; font-size: 1.1rem; color: #606060; line-height: 1.5rem; -webkit-appearance: none;
}
.tbl tr td input[type=number] {
	position: relative; display: inline; width: 20%; height: 2rem; padding: 0 1.25rem;
	border: 2px solid #cfcfcf; font-size: 1.1rem; color: #606060; line-height: 1.5rem;
}
.tbl tr td input[type=text] {
	position: relative; display: inline; width: 50%; height: 2rem; padding: 0 1.25rem;
	border: 2px solid #cfcfcf; font-size: 1.1rem; color: #606060; line-height: 1.5rem;
}
.parkCustomMarker {
	color:black; padding:5px; width:130px; height:53px;text-align:center; background-color:white;border:1px solid black;
}
#parkSumrTbody th td {
height:;
}
.popup-wrap .popup-con {padding:0.25rem 1.25rem 1.0rem 1.25rem;}
.popup-con th {font-size:20px;}
.popup-con td {font-size:20px;}
</style>
<script>
	var map;		// 카카오 맵 오브잭트
	var container;	// 카카오 맵이 올라가는 html 영역
	var mapLevel;	// 카카오 맵의 현재 레벨
	var markerList = [];	//마커의 관리 리스트
	var clickAddPark = null;
	var geocoder;	// 좌표변환 객체
	var clickParkInfo = null;
	
	var geoLat = '';	// geolocation 경도 좌표
	var groLng = '';	// geolocation 위도 좌표
	
	var param; // 주차장 탐색 범위 Param 및 탐색 최적화를 위한 이전 경위도 좌표 이용
	
	$(function(){
		$('#searchPark').hide();//불필요 header 내용
		
		var dateFormat 	= "yy-mm-dd";
		var d = new Date();
		var businessStartDt = $("#businessStartDt").datepicker();
		var businessEndDt = $("#businessEndDt").datepicker();
		
		businessStartDt.datepicker('setDate').on('change', function(){businessEndDt.datepicker('option', 'minDate', getDate(this));});
		businessEndDt.datepicker('setDate').on('change', function(){businessStartDt.datepicker('option', 'maxDate', getDate(this));});
		
		var getDate = function(el){
			var d;
			
			try{
				d = $.datepicker.parseDate(dateFormat, el.value);
			}catch(error){
				d = null;
			}
			return d;
		}
		
		container = document.getElementById('map');
		var headerHeight = document.getElementById('mapHeader').offsetHeight + document.getElementById('header').offsetHeight;
		var footerHeight = document.getElementById('mapFooter').offsetHeight;
		container.style.height = window.innerHeight - headerHeight - footerHeight + 'px';
		
		createMap();
		geolocation();
		searchPark();
		zoomChangeEvent();
		mapMoveEvent();
		clickEvent();
		
		// 조건변경 재검색 이벤트
		$("#businessSts, #progressSts").change(function() {
			searchPark();
		});
		
		$("#filter").click(function() {
			$("#contractStartDt").val($("input[name=contractStartDt]").val());
			$("#contractEndDt").val($("input[name=contractEndDt]").val());
			$("#operCoCd").val($("input[name=operCoCd]").val());
			$("#businessStartDt").val($("input[name=businessStartDt]").val());
			$("#businessEndDt").val($("input[name=businessEndDt]").val());
			
			$("#popup_filter").css("display", "table");
		});
		
		$(".popup-close").on("click", function() {
			$(this).closest(".popup-wrap").css("display", "none");
			searchPark();
		});
		
		$("#filterReset").click(function() {
			$("#contractStartDt").val("");
			$("#contractEndDt").val("");
			$("#operCoCd").val("");
			$("#businessStartDt").val("");
			$("#businessEndDt").val("");
		});
		
		$("#filterSetting").click(function() {
			$("input[name=contractStartDt]").val($("#contractStartDt").val());
			$("input[name=contractEndDt]").val($("#contractEndDt").val());
			$("input[name=operCoCd]").val($("#operCoCd").val());
			$("input[name=businessStartDt]").val($("#businessStartDt").val());
			$("input[name=businessEndDt]").val($("#businessEndDt").val());
			$(".popup-close").trigger('click');
		});
		
		$("#businessMgrBtn").click(function() {
			var userId = $("#businessMgrId").val();
			if(userId == "" || userId == null) {
				$("#businessMgrId").val($("#userId").val());
				$("#businessMgrBtn").html("내영업<br/>조회중");
			}else {
				$("#businessMgrId").val("");
				$("#businessMgrBtn").html("전체영업<br/>조회중");
			}
			searchPark();
		});
	});
	
	function geolocation() {
		if(navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(function(position) {
				geoLat = position.coords.latitude;
				groLng = position.coords.longitude;
				
			});
		}else {
			// 지원하지 않는 브라우져(웹환경)
		}
	}
	
	function createMap() {
		mapLevel = 3;

		// 경위도 좌표가 없을 경우 초기값 (주)한국전자금융 디폴트
		if(geoLat == null || geoLat == "") {//위도
			geoLat = 37.5291900635;
		}
		if(groLng == null || groLng == "") {//경도
			groLng = 126.9190292358;
		}
		
		var options = {
				center: new kakao.maps.LatLng(geoLat, groLng),
				level: mapLevel
		};
		
		map = new kakao.maps.Map(container, options);
	}
	
	function sumrPark() {//주차장 수 집계 레이어 처리
		removeMarker();
		clickAddParkCancel();
		$("#parkSumrPopup").show();
				
		// 재검색 시작
		var swLatLng = map.getBounds().getSouthWest();//남서쪽 좌표
		var neLatLng = map.getBounds().getNorthEast();//북동쪽 좌표
		
		var url = "<c:url value='/npmm/map/sumrPark.ajax'/>";
		var type = "GET";
		$("#minLat").val(swLatLng.getLat());
		$("#minLng").val(swLatLng.getLng());
		$("#maxLat").val(neLatLng.getLat());
		$("#maxLng").val(neLatLng.getLng());
		
		param = $('#searchFrm').serializeNpmsString();
		
		NpmsUtil.getAjaxData(url, type, param, function(result) {
			var list = result.data;
			var htmlTable = "";
			if(list == null || list.length == 0) {
				htmlTable += "<tr>";
				htmlTable += "	<td colspan='4'>검색된 주차장이 없습니다.</td>";
				htmlTable += "</tr>";
			}else {
				for(var idx = 0; idx < list.length; idx++) {
					if(idx % 2 == 0) {
						htmlTable += "<tr>";
						htmlTable += "	<th>"+list[idx].operCoNm+"</th>";
						htmlTable += "	<td>"+list[idx].operCoQtt+"</td>";
						if(idx == list[idx].length -1) htmlTable += "</tr>";
					}else {
						htmlTable += "	<th>"+list[idx].operCoNm+"</th>";
						htmlTable += "	<td>"+list[idx].operCoQtt+"</td>";
						htmlTable += "</tr>";
					}
				}
			}
			$("#parkSumrTbody").html(htmlTable);
		});
	}
	
	function searchPark() {
		$("#parkSumrPopup").hide();
		
		//재검색 전 마커 삭제
		removeMarker();
		
		// 재검색 시작
		var swLatLng = map.getBounds().getSouthWest();//남서쪽 좌표
		var neLatLng = map.getBounds().getNorthEast();//북동쪽 좌표
		
		var url = "<c:url value='/npmm/map/searchPark.ajax'/>";
		var type = "GET";
		$("#minLat").val(swLatLng.getLat());
		$("#minLng").val(swLatLng.getLng());
		$("#maxLat").val(neLatLng.getLat());
		$("#maxLng").val(neLatLng.getLng());
		
		param = $('#searchFrm').serializeNpmsString();
		
		NpmsUtil.getAjaxData(url, type, param, function(result) {
			result.data.forEach(function(park) {
				createMarker(park); 
			});
		});
	}
	
	function removeMarker() {
		for(var idx = 0; idx < markerList.length; idx++) {
			markerList[idx].setMap(null);
		}
		markerList = null;//혹시 몰라서 널 처리 후 초기화
		markerList = [];
	}
	
	function createMarker(park) {
		// Info창 생성
 		var position = new kakao.maps.LatLng(park.entY, park.entX);
		var iwContent = document.createElement('div');
		//iwContent.className = 'parkCustomMarker';
		
		//var iwContentHtml = '<div style="background: url(&quot;http://t1.daumcdn.net/localimg/localimages/07/mapjsapi/2x/triangle.png&quot;) 0% 0% / 16px 15px no-repeat;width: 16px;'
		var iwContentHtml = '<div style="background: url(&quot;/resources/images/npmm/triangle.png&quot;) 0% 0% / 16px 15px no-repeat;width: 16px;'
		+'height: 15px;"></div>';
		
		iwContent.innerHTML = iwContentHtml;
		iwContent.onclick = function () {
			$("#businessParkNo").val(park.businessParkNo);
			$("#address").html(park.address);
			$("#macCoNm").html(park.macCoNm);
			var startDt = park.contractStartDt==null||park.contractStartDt==""?"?":park.contractStartDt;
			var endDt = park.contractEndDt==null||park.contractEndDt==""?"?":park.contractEndDt;
			$("#contractDt").html(startDt + " ~ " + endDt);
			$("#businessMgrNm").html(park.businessMgrNm);
			$("#remark").html("<pre style='line-height:19px; margin:0 0;'>"+park.remark+"</pre>");
			$("#popup_parkInfo").css("display", "table");
		}
		
		var infowindow = new kakao.maps.CustomOverlay({
		//var infowindow = new kakao.maps.InfoWindow({
			map:map,
			position:position,
			content:iwContent,
			clickable:true,
			removable:false
		});
		infowindow.setMap(map);
		var iwContentHtml2 = '<div style="position: absolute;left:-58px;top:-48px;color:black; padding:5px; width:130px; height:50px;text-align:center; background-color:white;border:1px solid black;">';
		iwContentHtml2 += '	' + park.bdNm + '<br/>';
		if(park.contractDiff < 18 || park.businessDiff > 30) {
			iwContentHtml2 += '	<div class="center" style="background-color: red;">';
		}else {
			iwContentHtml2 += '	<div class="center">';
		}
		iwContentHtml2 += '	' + park.operCoCd + ' / ' + (park.contractDiff==null?"?":park.contractDiff) + ' / ' + park.progressNm;
		iwContentHtml2 += '	</div></div>';
		iwContentHtml = iwContentHtml2 + iwContentHtml;
		
		iwContent.innerHTML = iwContentHtml;
		markerList.push(infowindow);
	}
	
	function zoomChangeEvent() {
		kakao.maps.event.addListener(map, 'zoom_changed', function() {
			var level = map.getLevel();
			
			if(level > 7) {//집계 View
				mapLevel = level;
				sumrPark();
			} else {
				if(mapLevel > 7) {
					mapLevel = level;
					searchPark();
				} else if(mapLevel > level) {
					// 단순 확대로 조회 불필요
					
				} else {
					mapLevel = level;
					searchPark();
				}
			}
		});
	}
	
	function mapMoveEvent() {
		kakao.maps.event.addListener(map, 'dragend', function() {
			clickAddParkCancel();
			if(mapLevel > 7) {
				sumrPark();
			}else {
				searchPark();
			}
		});
	}
	
	function addPark() {
		var params = {};
		if(clickParkInfo == null) {
			location.href = '/npmm/parkBusinessHistReg';
		}else {
			params = {
				admCd:clickParkInfo.admCd,
				rnMgtSn:clickParkInfo.rnMgtSn,
				udrtYn:clickParkInfo.udrtYn,
				buldMnnm:clickParkInfo.buldMnnm,
				buldSlno:clickParkInfo.buldSlno,
				entX:clickParkInfo.entX,
				entY:clickParkInfo.entY,
				bdNm:encodeURIComponent(clickParkInfo.bdNm),
				postNo:clickParkInfo.zipNo,
				address:encodeURIComponent(clickParkInfo.adress)
			};
			NpmsUtil.getAjaxData('/npmm/map/checkAlreadyParkReg.ajax', 'POST', $.param(params), function(rtn) {
				if(rtn.data == true) {
					//alert($.param(params));
					location.href = '/npmm/parkBusinessHistReg?' + $.param(params);
				}else {
					alert('이미 등록된 현장입니다.');
				}
			});
		}
	}
	
	function clickEvent() {
		geocoder = new kakao.maps.services.Geocoder();
		
		kakao.maps.event.addListener(map, 'click', function(mouseEvent) {
			if(clickAddPark == null) {
				if(mapLevel > 7) return;
				geocoder.coord2Address(mouseEvent.latLng.getLng(), mouseEvent.latLng.getLat(), function(result, status) {
					if(status === kakao.maps.services.Status.OK) {
						var address = result[0].road_address==null?result[0].address:result[0].road_address;
						var param = {keyword:address.address_name};
						NpmsUtil.getAjaxData('/npmm/map/adressSearchByKeyword.ajax', 'POST', $.param(param), function(rtn) {
							if(rtn.data == null) {
								//alert("선택된 곳의 주소가 검색되지 않습니다.");
								return;
							}
							// rtn = JosuVO
							rtn.data.entX = mouseEvent.latLng.getLng();
							rtn.data.entY = mouseEvent.latLng.getLat();
							var address = rtn.data.roadAddr == null?rtn.data.jibunAddr:rtn.data.roadAddr;
							rtn.data.adress = address;
							clickParkInfo = rtn.data;
							
							var addressList = address.split(" ");
							address = '';
							for(var idx = 0; idx < addressList.length; idx++) {
								address += addressList[idx] + '&nbsp;';
								if(idx % 2 == 1 && idx+1 != addressList.length) {
									address += '<br/>';
								}
							}
							
							var addParkDiv = document.createElement('div');
							addParkDiv.className = 'overlay';
							var addPark = '';
							addPark += '<div style="background-color:white; border:1px solid black;">';
							addPark += '	<table class="tbl tbl-x" style="width: 140px;">';
							addPark += '		<caption>신규 주차장 정보</caption>';
							addPark += '		<colgroup>';
							addPark += '			<col width="50" />';
							addPark += '			<col width="150" />';
							addPark += '		</colgroup>';
							addPark += '		<tbody>';
							addPark += '			<tr>';
							addPark += '				<th>건물명</th>';
							addPark += '				<td>'+rtn.data.bdNm+'</td>';
							addPark += '			</tr>';
							addPark += '			<tr>';
							addPark += '				<th>주소</th>';
							addPark += '				<td>'+address+'</td>';
							addPark += '			</tr>';
							addPark += '		</tbody>';
							addPark += '	</table>';
							addPark += '</div>';
							addPark += '<div style="margin-left:92px;background: url(&quot;/resources/images/npmm/triangle.png&quot;) 0% 0% / 16px 15px no-repeat;width: 16px;height: 15px;"></div>';
							addParkDiv.innerHTML = addPark;
							var position = new kakao.maps.LatLng(mouseEvent.latLng.getLat(), mouseEvent.latLng.getLng());
							clickAddPark = new kakao.maps.CustomOverlay({
								map:map,
								position:position,
								content:addParkDiv,
								yAnchor:1
							});
							clickAddPark.setMap(map);
							$("#addParkBtn").html("선택된<br/>주차장<br/>등록하기").css("background-color","#228dc5").css("color","#fff");
						});
					}
				});
			}else {
				clickAddParkCancel();
			}
		});
	}
	
	function clickAddParkCancel() {
		if(clickAddPark != null) {
			clickAddPark.setMap(null);
			clickAddPark = null;
			clickParkInfo = null;
		}
		$("#addParkBtn").html("주차장<br/>등록하기").css("background-color","#fff").css("color","black");
	}
	
	function maxLengthCheck(object) {
		if(object.value.length > object.maxLength) {
			object.value = object.value.slice(0, object.maxLength);
		}
	}
	
	function detailPark() {
		location.href = "<c:url value='/npmm/parkBusinessHistView?businessParkNo='/>" + $("#businessParkNo").val();
	}
</script>
</head>
<body>
	<%@include file="/WEB-INF/jsp/npms/npmm/include/header.jsp"%>
	<div id="container">
		<form:form id="searchFrm" name="searchFrm" onsubmit="return false">
		<input type="hidden" id="minLat" name="minLat">
		<input type="hidden" id="minLng" name="minLng">
		<input type="hidden" id="maxLat" name="maxLat">
		<input type="hidden" id="maxLng" name="maxLng">
		<input type="hidden" name="contractStartDt">
		<input type="hidden" name="contractEndDt">
		<input type="hidden" name="operCoCd">
		<input type="hidden" name="businessStartDt">
		<input type="hidden" name="businessEndDt">
		
		<div class="popup-wrap" id="popup_filter">
			<div class="popup-in">
				<div class="popup">
					<div class="popup-tit">
						<strong>필터 설정</strong>
						<button type="button" class="popup-close">
							<img src="/resources/images/npmm/ico-popup-close.png" alt="닫기" />
						</button>
					</div>
					<div class="popup-con" style="padding:0.5rem 1.25rem 1rem 1.25rem">
						<table id="" class="tbl tbl-x">
							<colgroup>
								<col width="33%" />
								<col width="67%" />
							</colgroup>
							<tbody>
								<tr>
									<th scope="row">남은계약기간</th>
									<td scope="row">
										<input type="number" pattern="\d*" id="contractStartDt" maxlength="2" oninput="maxLengthCheck(this)" style="width:50px;height:32px;font-size:14px;margin:0 0 3px 0;">&nbsp;개월 이상&nbsp;~&nbsp;<br/>
										<input type="number" pattern="\d*" id="contractEndDt" maxlength="2" oninput="maxLengthCheck(this)" style="width:50px;font-size:14px;height:32px;">&nbsp;개월 이하
									</td>
								</tr>
								<tr>
									<th>운영사</th>
									<td>
										<select id="operCoCd" class="conditionSelect" style="height:32px;">${operCoCdOptions}</select>
									</td>
								</tr>
								<tr>
									<th>최종방문일</th>
									<td>
										<input type="text" name="businessStartDt" id="businessStartDt" readonly="readonly" style="width:105px;height:32px;font-size:14px;magin:0 0 7px 0;"/>&nbsp;부터<br/>
										<input type="text" name="businessEndDt" id="businessEndDt" readonly="readonly" style="width:105px;height:32px;font-size:14px;"/>&nbsp;까지
									</td>
								</tr>
							</tbody>
						</table>
						<br/>
						<button id="filterReset" class="conditionBtn">필터 초기화</button>
						<button id="filterSetting" class="conditionBtn" style="float:right;">적용</button>
					</div>
				</div>
			</div>
		</div>
		
		<div id="mapHeader" class = "mapHeader">
			<div style="width:19%;height:90%;float:left;">
				<button class="conditionBtn" id="filter" style="width:90%;">필터</button>
				<input type="hidden" id="userId" value="${userId}"/>
				<input type="hidden" id="businessMgrId" name="businessMgrId">
				
			</div>
			<div style="width:19%;height:90%;float:left;">
				<button class="conditionBtn" id="businessMgrBtn" style="width:90%;">전체영업<br/>조회중</button>
			</div>
			<div style="width:45%;float:left;margin-top:5px;">
				<select id="businessSts" name="businessSts" class="conditionSelect" >${businessStsOptions}</select><br/>
				<select id="progressSts" name="progressSts" class="conditionSelect" style="margin-top:4px;">${bizProgressStsOptions}</select>
			</div>
			<div style="width:17%;height:90%;float:left;">
				<button id="addParkBtn" onclick="addPark();" style="width:95%; height:90%; margin:5px 10% 5px 10%; border:1px solid #c0c0c0; background-color:#fff !important;">
					주차장<br/>등록하기
				</button>
			</div>
		</div>
		</form:form>
		<!-- container -->
		<div id="map" style="width:100%;"></div>
		
		<div id="mapFooter" class = "mapFooter">
			
		</div>
	</div>
	<!-- // container -->
	
	<div class="popup-wrap" id="popup_parkInfo">
		<div class="popup-in">
			<div class="popup">
				<div class="popup-tit">
					<strong>주차장 정보</strong>
					<button type="button" class="popup-close">
						<img src="/resources/images/npmm/ico-popup-close.png" alt="닫기" />
					</button>
				</div>
				<input id="businessParkNo" type="hidden" />
				<div class="popup-con">
					<button onclick="detailPark()" style="float:right;padding:0 5px; margin: 2px 2px 2px 2px; border:1px solid #c0c0c0; background-color:#fff !important; font-size:1.3rem; color:#606060; line-height:27px;">자세히</button>
					<table id="addrList" class="tbl tbl-x">
						<colgroup>
							<col width="27%" />
							<col width="73%" />
						</colgroup>
						<tbody>
							<tr>
								<th scope="row">주소</th>
								<td scope="row" id="address" style="line-height:23px"></td>
							</tr>
							<tr>
								<th>운영사</th>
								<td id="macCoNm"></td>
							</tr>
							<tr>
								<th>계약기간</th>
								<td id="contractDt"></td>
							</tr>
							<tr>
								<th>영업자</th>
								<td id="businessMgrNm"></td>
							</tr>
							<tr>
								<th>특이사항</th>
								<td id="remark"></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
	
	<div id="parkSumrPopup" style="bottom:0px;width:100%;height:90px;position:absolute;background-color:white;z-index:10;">
		<span style="font-size:1.4rem; padding-left: 1rem;">주차장 집계 내역</span>
		
		<table id="parkSumrTable" class="tbl" style="width:100%; margin-top:0.5rem;">
			<colgroup>
				<col width="25%" />
				<col width="25%" />
				<col width="25%" />
				<col width="25%" />
			</colgroup>
			<tbody id="parkSumrTbody">
				
			</tbody>
		</table>
	</div>
	<%@include file="/WEB-INF/jsp/npms/npmm/include/popupAndLoadingBar.jsp"%>
	<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=9aa0593ad1e7d0feaf7549c495435807&libraries=services"></script>
</body>
</html>