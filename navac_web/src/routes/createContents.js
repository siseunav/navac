import React, { useState } from 'react';
import { styled } from "styled-components";
import { auth, db, storage } from "../firebase";
import { getDownloadURL, ref, uploadBytes } from "firebase/storage";
import { serverTimestamp,addDoc, collection, updateDoc } from "firebase/firestore";
// import './NewPageEditor.css';
import {
    PostTextArea,
    ContentFormWrapper,
    PostSubmitBtn,
    ButtonContainer,
    PagePreview ,
    AttachContentsInput,
    AttachContentsButton, 
} from "../components/auth-Components";

const Container =styled.div`
    height: 100%;
    display: flex;
    flex-direction: column;
    width: 100%;
    padding:50px 0px; 

    /* 반응형 크기 조정 */
    width: 100%;
    max-width: 1000px; /* 최대 너비를 제한 */
    margin: 0 auto; /* 가운데 정렬 */
`;
const PAGE_HEIGHT = 1122; // A4 용지 높이 (픽셀 기준, 96 DPI로 설정)

export default function NewPageEditor(){
    const [pages, setPages] = useState([
        { title: "첫 번째 페이지", subtitle: "페이지 1의 부제목", content: "" },
    ]);
    const [content, setContent] = useState('');
    const [shully, setShully] = useState("");
    const [isSaving, setSaving] = useState(false);
    const [file, setFile] = useState(null);
    
    const onChange = (e) => {
        setContent(e.target.value||"");// 문자열 아니면 공백
    };
   
    const handleSave = () => {
        if (content.trim() === '') {
            alert('내용이 비어 있습니다. 내용을 입력해 주세요.');
            return;
        }
        const pages = getPagedContent();
        console.log('저장된 내용 (페이지):', pages);
        alert(`내용이 저장되었습니다! 총 ${pages.length}페이지.`);
    };
    const onFileChange = (e) => {
        // ts 타입 검증 대체 코드, {files} 로 직접적인 값으로 if문 작성 대신 변수값 자체에 반복문 결과를 저장해줌.
        const file = e.target.files?.[0] || null; // 파일 변수값을 확인.
        setFile(file instanceof File ? file : null); // 파일이면 저장, 아니면 상태 초기화
    };


    // 작성한 파일을 저장하고 생성할 수 있는 기능 구현 중.
    const onSubmit = async(e) => {
        e.preventDefault();
        const user = auth.currentUser;
        if(!user ||isSaving || shully==="" || shully.length>5000) return;
        try {
            setSaving(true);
            //게시물을 하나의 변수로 명명
           const doc = await addDoc(collection(db, "shullys"),{
                shully,
                createdAt: Date.now(),
                username: user.displayName || "Anonymous",
                userid: user.uid,
            });
            //파일이 있을경우 파일을 추가하는 코드.
            if(file){
                //저장하는 url 경로, 해당 경로는 죄가 없다.
                const locationRef = ref(
                    storage,`shullys/${user.uid}/${doc.id}`
                );
                const uploadResult = await uploadBytes(locationRef, file);
                    console.log("upload complete");
                //posting err why:  TypeError: Cannot read properties of undefined (reading 'ref') at onSubmit (bundle.js:926:104) 터미널 상 에러가 남. -> 난 snapshot 기능을 쓰기 때문에, 직접 참조변수를 받아와야 한다. then() 메소드로 인해 변수값 저장에 에러가 나서 발생됨.
                const photoURL = await getDownloadURL(uploadResult.ref);
                //serverTimestamp가 현재 작업시엔 편하지만 데이터 전송 속도측면에서 나중에 Date.now(); 로 바꿀예정 
                // const timeStamp = serverTimestamp();
                
                //fireDB에 파일 url 을 임의로 추가. json 형태로 item 명만 입력해 주는 듯.
                //저장 시간도 추적가능 하게 함.
                await updateDoc(doc, {
                        photo: photoURL,
                        // createdAt: timeStamp,
                });}                        
                setShully("");
                setFile(null); 
             } catch(e){
                    console.log("posting err why: ",e);              
                } finally{
                    setSaving(false);
                }
            };
            const addPage = () => {
                setPages([
                    ...pages,
                    { title: `페이지 ${pages.length + 1}`, subtitle: "", content: "" },
                ]);
            };
            
            const updatePage = (index, field, value) => {
                const updatedPages = [...pages];
                updatedPages[index][field] = value;
                setPages(updatedPages);
            };
    const getPagedContent = () => {
        const lines = content.split('\n');
        let pages = [];
        let currentPage = '';
        let currentHeight = 0;

        lines.forEach(line => {
            const lineHeight = 20; // 예상 라인 높이 (픽셀)
            if (currentHeight + lineHeight > PAGE_HEIGHT) {
                pages.push(currentPage);
                currentPage = '';
                currentHeight = 0;
            }
            currentPage += line + '\n';
            currentHeight += lineHeight;
        });

        if (currentPage.trim()) {
            pages.push(currentPage);
        }

        return pages;
    };

    return (
<Container>
    <ContentFormWrapper onSubmit={onSubmit}>
        <h1>새 페이지 추가</h1>
        <p>아래에 페이지별 제목과 부제목을 입력하세요.</p>
        {pages.map((page, index) => (
            <div key={index} className="page-editor">
                < AttachContentsButton placeholder="title?">
                    <input
                        type="text"
                        value={page.title}
                        onChange={(e) => updatePage(index, "title", e.target.value)}
                    />
                </ AttachContentsButton >
                < AttachContentsButton placeholder="subtitle?">
                    <AttachContentsInput
                        type="text"
                        value={page.subtitle}
                        onChange={(e) =>
                            updatePage(index, "subtitle", e.target.value)
                        }
                    />
                </ AttachContentsButton >
                <PostTextArea
                    placeholder={`페이지 ${index + 1} 내용을 입력하세요...`}
                    value={page.content}
                    onChange={(e) => updatePage(index, "content", e.target.value)}
                />
            </div>
        ))}
        <ButtonContainer>
            <AttachContentsButton htmlFor="file-input">파일 선택</AttachContentsButton>
            <AttachContentsInput
                id="contents-upload"
                type="file"
                onChange={onFileChange}
            />
            <PostSubmitBtn
                type="button"
                onClick={addPage}
                value="페이지 추가"
            />
            <PostSubmitBtn
                type="submit"
                disabled={isSaving}
                value={isSaving ? "Saving..." : "저장"}
            />
        </ButtonContainer>
    </ContentFormWrapper>

    <PagePreview>
        {pages.map((page, index) => (
            <div key={index} className="page">
                <h2>{page.title}</h2>
                <h3>{page.subtitle}</h3>
                <pre>{page.content}</pre>
            </div>
        ))}
    </PagePreview>
</Container>
        );
};


