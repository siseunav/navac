import React, { Component } from "react";
import { styled } from "styled-components";
import { auth } from "../firebase";
import { withRouter } from "react-router-dom";
import { useNavigate } from "react-router-dom";
import { GithubAuthProvider, signInWithPopup } from "firebase/auth";
import {
    GithubBtn,ButtonContainer
  } from "../components/auth-Components";
import cloudelogo from "../styled/imgs/cloude.svg";
const Log = styled.img`
  height: 20px;
`;

const MessageWrapper = styled.div`
  color: red;
  font-size: 14px;
  text-align: center;
  white-space: pre-line; /* 줄바꿈과 공백을 처리 */
`;

class GithubButton extends Component {
  constructor(props) {
    super(props);
    this.state = {
    // 계정생성 비활성화. 생명주기 함수로 급하게 막음. 
      isBlocked: true || props.AccountCreationDisabled,
      errorMessage:  "Creating a new account \n currently unavailable."
    };
  }
//정지
  componentDidMount() {
    const { AccountCreationDisabled } = this.props;

    if (AccountCreationDisabled) {
      this.setState({
        isBlocked: true,
        errorMessage: "계정 생성이 비활성화되었습니다. 점검 후 다시 시도해 주세요.",
      });
    }
  }
//활성
  componentDidUpdate(prevProps) {
    const { AccountCreationDisabled } = this.props;

    if (prevProps.AccountCreationDisabled !== AccountCreationDisabled) {
      this.setState({
        isBlocked: AccountCreationDisabled,
        errorMessage: AccountCreationDisabled
          ? "계정 생성이 비활성화되었습니다. 점검 후 다시 시도해 주세요."
          : "",
      });
    }
  }

  onClick = async () => {
    const { isBlocked } = this.state;

    if (isBlocked) {
      alert("계정 생성이 비활성화되었습니다.");
      return;
    }

    try {
      const provider = new GithubAuthProvider();
      await signInWithPopup(auth, provider);
      this.props.navigate("/");
    } catch (error) {
      console.error(error);
      this.setState({ errorMessage: "로그인 중 오류가 발생했습니다. 다시 시도해 주세요." });
    }
  };

  render() {
    const { isBlocked, errorMessage } = this.state;

    return (
      <>
        <GithubBtn onClick={this.onClick} disabled={isBlocked}>
          <Log src={cloudelogo} />
          Continue with Github
        </GithubBtn>
        {isBlocked && (
          <MessageWrapper>
            {errorMessage}
          </MessageWrapper>
        )}
      </>
    );
  }
}

// `useNavigate`를 사용하여 `navigate`를 전달
const GithubButtonWithNavigate = (props) => {
  const navigate = useNavigate();
  return <GithubButton {...props} navigate={navigate} />;
};

export default GithubButtonWithNavigate;
