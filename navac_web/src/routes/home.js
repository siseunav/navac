// import { auth } from "../firebase";
// import {styled} from "styled-components";
import { useNavigate } from "react-router-dom";
import PostForm from "../components/postForm";
import { HomeWrapper,GlobalStyles } from "../components/auth-Components";
import Timeline from "../components/timeline";
import React from "react";
export default function Home() {
    const navigate = useNavigate(); // 
    // const logOut = () => {
    //     auth.signOut().then(() => {
    //         navigate("/login");
    //     }).catch((error) => {
    //         console.error("Logout failed:", error);
    //     });
    // };
        
    return (

        <HomeWrapper>
            <GlobalStyles/>
            <PostForm/>
            <Timeline />
        </HomeWrapper>
    );
}