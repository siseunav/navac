import { Navigate } from "react-router-dom";
import { auth } from "../firebase";
import React, { useState, useEffect } from "react";
//children은 component 내부의 모든 것을 의미. 해당 라우터로 감싸주면 하기의 if문이 작용된다. : login 페이지로 이동. 2차 수정: 타입스크립트 일반 자바스크립트로 전환.
export default function ProtectedRoute({children}) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    useEffect(()=> {
        //현재 유저의 로그인 상태를 확인한다.
        const onUser = auth.onAuthStateChanged((currentUser)=>{
            setUser(currentUser);
            setLoading(false);        
        });
        return() => onUser();//user의 로그인 후 성능의 최적화를 위해 onAuthStateChanged 구독을 해제.
    //useEffect []에 props 혹은 특정 상태를 입력시 재 랜더링 작업.
    },[]);

    if (loading) {
        return <div>Loading...</div>; // 로딩 화면 표시
    }

    if (!user) {
        return <Navigate to="/login" />; // 인증되지 않은 경우 로그인 페이지로 리다이렉트
    }

    return children; // 인증된 경우 자식 컴포넌트 렌더링
}