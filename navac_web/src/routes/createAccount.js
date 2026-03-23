import { createUserWithEmailAndPassword, updateProfile } from "firebase/auth";
import { useState } from "react";
import { styled } from "styled-components";
import { auth } from "../firebase";
import { Link, useNavigate } from "react-router-dom";
import {
  Form,
  Error,
  Input,
  Switcher,
  Title,
  Wrapper,ButtonContainer
} from "../components/auth-Components";
import GithubBotton from "../components/githubBtn";

export default function CreateAccount() {
  const navigate = useNavigate();
  const [isLoading, setLoading] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [err, setErr] = useState("");

  const validateInputs = () => {
    // Name validation
    if (typeof name !== "string" || name.trim().length < 2) {
      setErr("Name must be at least 2 characters long.");
      return false;
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (typeof email !== "string" || !emailRegex.test(email)) {
      setErr("Please provide a valid email address.");
      return false;
    }

    // Password validation
    if (typeof password !== "string" || password.length < 6) {
      setErr("Password must be at least 6 characters long.");
      return false;
    }

    return true;
  };

  const onChange = (e) => {
    const { name, value } = e.target;
    if (name === "name") {
      setName(value);
    } else if (name === "email") {
      setEmail(value);
    } else if (name === "password") {
      setPassword(value);
    }
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    setErr("");

    // Validate inputs before proceeding
    if (isLoading || !validateInputs()) return;

    try {
      setLoading(true);

      // Create user
      const credentials = await createUserWithEmailAndPassword(auth, email, password);
      console.log(credentials.user);

      // Update profile
      await updateProfile(credentials.user, { displayName: name });

      // Redirect to home
      navigate("/");
    } catch (e) {
      console.error(e);

      if (e.code === "auth/email-already-in-use") {
        setErr("That email already exists.");
        alert("이미 존재하는 계정입니다.");
      } else {
        setErr("An error occurred. Please try again.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <Wrapper>
      <Title>Join SHULLY</Title>
      <Form onSubmit={onSubmit}>
        <Input
          onChange={onChange}
          name="name"
          value={name}
          placeholder="Name"
          type="text"
          required
        />
        <Input
          onChange={onChange}
          name="email"
          value={email}
          placeholder="Email"
          type="email"
          required
        />
        <Input
          onChange={onChange}
          name="password"
          value={password}
          placeholder="Password"
          type="password"
          required
        />
        <Input
          type="submit"
          value={isLoading ? "Loading.." : "Create Account"}
        />
      </Form>
      {err !== "" && (
        <Error>
          <p>{err}</p>
        </Error>
      )}
      <ButtonContainer>
      <Switcher>
        Already have an account?
        <Link to="/login"> Log in &rarr;</Link>
      </Switcher>
      <GithubBotton />
      </ButtonContainer>
    </Wrapper>
  );
}
