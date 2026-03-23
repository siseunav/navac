import { useState } from "react";
import { auth } from "../firebase";
import { Link,useNavigate } from "react-router-dom";
import { Navigate } from "react-router-dom";
import { FirebaseError } from "firebase/app";
import { signInWithEmailAndPassword } from "firebase/auth";
import {
    Form,ButtonContainer,
    Error,
    LoginButton,LoginInput,LoginTitle,CreateAccountBtn,
    Wrapper,Switcher,ShullyText
  } from "../components/auth-Components";
import GithubBotton from "../components/githubBtn";
import React from "react";

//react component 명명은 대문자로 시작!
export default function LoginAccount(){
    const navigate = useNavigate();
    const [isLoading, setLoading] = useState(false);
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [err, setErr] =useState("");
    const onChange = (e) => {
        const { name, value } = e.target;
        if (name === "email") {
            setEmail(value);
        } else if (name === "password") {
            setPassword(value);
        }
    };

    const onSubmit = async(e) => {
        e.preventDefault();
        setErr("");
        if(isLoading || email ==="" || password==="") return;
        try {
            setLoading(true);
            await signInWithEmailAndPassword(auth, email, password);
            navigate("/");
        } catch(e){
           //setError
           if(e instanceof FirebaseError){
            console.log(e.code, e.massage)
            setErr(e.message); 
           }
        } finally {
            setLoading(false);
        }
        console.log(email, password);
    }
    return( 
     <Wrapper>
            <LoginTitle>
            Login into{`\n`} 
            <ShullyText>SHULLY</ShullyText>
            </LoginTitle>   
        <Form onSubmit ={onSubmit}>
            <LoginInput onChange={onChange} name="email" value = {email} placeholder="Email" type= "email" required/>
            <LoginInput onChange={onChange} name="password" value = {password} placeholder="Password" type= "password" required/>
            <LoginInput type="submit"  value={isLoading? "Loading.." : "Log in"}/>           
        </Form>
        <ButtonContainer>
            <CreateAccountBtn onClick={() => navigate("/createAccount")}>
                Join into Shully</CreateAccountBtn>
                {/* <Switcher>
                    <Link to="/createAccount">Create one &rarr;</Link>
                </Switcher> */}
            <GithubBotton/>
       </ButtonContainer>
 {/* 상기의 setErr 에 값을 세팅해서 err 메세지를 띄운다.*/}
       {err !== ""? <Error> {err}</Error> : null}
    </Wrapper>
    );
}