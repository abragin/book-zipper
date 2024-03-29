// Entry point for the build script in your package.json
//import "@hotwired/turbo-rails"
//import "./controllers"
//import * as bootstrap from "bootstrap" //import "./components"
import React from "react";
import ReactDOM from "react-dom/client";

const chapterZipDebug = {
  paragraphsSource: [
    {id: 10, content: "On returning from the review, Kutúzov took the Austrian general into his private room and"},
    {id: 11, content: "calling his adjutant, asked for some papers relating to the condition of the troops on their arrival, and the letters that had come from the Archduke Ferdinand,"},
    {id: 12, content: "“Ah!...” said Kutúzov glancing at Bolkónski as if by this exclamation"},
    {id: 13, content: "he was asking the adjutant to wait, and he went on with the conversation in French."},
    {id: 15, content: "All I can say, General,” said he with a pleasant elegance of expression and intonation that obliged one to listen to each deliberately spoken word. It was evident that Kutúzov himself listened with pleasure to his own voice. “All I can say, General, is that if the matter depended on my personal wishes, the will of His Majesty the Emperor Francis would have been fulfilled long ago. I should long ago have joined the archduke."},
    {id: 16, content: "And believe me on my honour that to me personally it would be a pleasure to hand over the supreme command of the army into the hands of a better informed and more skillful general—of whom Austria has so many—and to lay down all this heavy responsibility. But circumstances are sometimes too strong for us, General.”"},
    {id: 19, content: "And Kutúzov smiled in a way that seemed to say, “You are quite at liberty not to believe me and I don’t even care whether you do or not, but you have no grounds for telling me so. And that is the whole point.”"}
  ],
  paragraphsTarget: [
    {id: 20, content: "Возвратившись со смотра, Кутузов, сопутствуемый австрийским генералом, прошел в свой кабинет и,"},
    {id: 21, content: "— A!... — сказал Кутузов, оглядываясь на Болконского, как будто этим словом приглашая адъютанта подождать, и продолжал по-французски начатый разговор."},
    {id: 25, content: "— Я только говорю одно, генерал, — говорил Кутузов с приятным изяществом выражений и интонации, заставлявшим вслушиваться в каждое неторопливо-сказанное слово. Видно было, что Кутузов и сам с удовольствием слушал себя. — Я только одно говорю, генерал, что ежели бы дело зависело от моего личного желания, то воля его величества императора Франца давно была бы исполнена. Я давно уже присоединился бы к эрцгерцогу. И верьте моей чести, что для меня лично передать высшее начальство армией более меня сведущему и искусному генералу, какими так обильна Австрия, и сложить с себя всю эту тяжкую ответственность, для меня лично было бы отрадой."},
    {id: 26, content: "Но обстоятельства бывают сильнее нас, генерал."},
    {id: 28, content: "И Кутузов улыбнулся с таким выражением, как будто он говорил: «Вы имеете полное право не верить мне, и даже мне совершенно всё равно, верите ли вы мне или нет, но вы не имеете повода сказать мне это. И в этом-то всё дело»."}
  ],
  connections: [[0,0], [2,1], [4,2]],
  skippedSource: [1],
  skippedTarget: [],
  unverifiedConnectionSourceIds: [2,4],
  verifiedPMCursorSourceId: 0,
  //inconsistentConnectionSourceId: 4,
}

class Paragraph extends React.Component{
 render(){
   const cssClasses = (this.props.selected === this.props.index) ? "paragraph selected" : "paragraph"
   const selectBTN = (this.props.index > 0 && !this.props.skipped) ? (
     <button
       key="selectBTN"
       type="button"
       onClick={() => this.props.handleClick(this.props.index, this.props.src)}>
       {(this.props.selected === this.props.index) ? "-" : "+"}
     </button>
   ) : null;
   const skipBTN = (this.props.offset > 0) ? (
     <button
       key="skipBTN"
       type="button"
       onClick={() => this.props.handleParagraphSkip(this.props.index, this.props.src)}>
       {this.props.skipped ? "Unskip" : "Skip"}
     </button>
   ) : null;
   const buttons = (<div className={this.props.src==="source" ? "selectBtnSrc" : "selectBtnTgt"}>
       {this.props.src==="source" ? [skipBTN, selectBTN] : [selectBTN, skipBTN]}
       </div>);
   return (<div className={cssClasses} >
     {buttons}
     <span className={this.props.skipped ? "skippedParagraph" : 'paragraphContent'}>
       {this.props.paragraph.content}
       </span>
   </div>)
 }
}

class ParagraphZipStatus extends React.Component{
  render(){
    const verified = this.props.sourceParagraphId < this.props.verifiedPMCursorSourceId
    //const consistent = this.props.sourceParagraphId < this.props.inconsistentConnectionSourceId
    const moveVerifiedDownBTN = <button
       key="verifyDownBTN"
       onClick={() => this.props.handleChangeVerified(this.props.idx+1)}>
       V
    </button>
    const moveVerifiedUpBTN = <button
       key="verifyUpBTN"
       onClick={() => this.props.handleChangeVerified(this.props.idx)}>
       Λ
    </button>
    const rematchBelowBTN = <button
       key="rematchBelowBTN"
       id="rematch-below"
       name="rematch_from_here"
       title="Re-match from here"
       onClick={() => this.props.handleRematchBelow(this.props.idx)}>
       VVV
    </button>
    const showRematchBtn = this.props.sourceParagraphId === this.props.verifiedPMCursorSourceId;
    const changeVerifiedBTN = verified ? moveVerifiedUpBTN : moveVerifiedDownBTN;
    const tdClass = verified ? "paragraphStatusVerified" : "paragraphStatusUnverified";
    const mergePrevBTN = (this.props.sourceIndex > 0) ? (
      <button
        key="mergeBTN"
        type="button"
        onClick={() => this.props.handleParagraphUnion(this.props.sourceIndex)}>
        Remove connection </button>
    ) : null;
    const topCol = this.props.connectionVerified ? "topGreen" : "topYellow"
    const bottomCol = this.props.nextConnectionVerified ? "bottomGreen" : "bottomYellow"

    return (<td className={"status " + topCol + " " + bottomCol + " " + tdClass}>
              {mergePrevBTN}
              {changeVerifiedBTN}
              {showRematchBtn ? rematchBelowBTN : null}
            </td>
               )
  }
}

class ParagraphZip extends React.Component{
  render(){
    const ps_source = range(this.props.paragraphZip.sourceIds).map((sInd, i) => (
      <Paragraph
        index={sInd}
        key={sInd}
        paragraph={this.props.paragraphsSource[sInd]}
        selected={this.props.selectedSource}
        src='source'
        handleClick={this.props.handleClick}
        handleParagraphSkip={this.props.handleParagraphSkip}
        offset={i}
        skipped={this.props.skippedSource.has(sInd)}
      />))
    const ps_target = range(this.props.paragraphZip.targetIds).map((tInd, i) => (
      <Paragraph
        index={tInd}
        key={tInd}
        paragraph={this.props.paragraphsTarget[tInd]}
        selected={this.props.selectedTarget}
        src='target'
        handleClick={this.props.handleClick}
        handleParagraphSkip={this.props.handleParagraphSkip}
        offset={i}
        skipped={this.props.skippedTarget.has(tInd)}
      />))
    const pz_status = (<ParagraphZipStatus
                        sourceParagraphId={this.props.paragraphZip.sourceIds[0]}
                        verifiedPMCursorSourceId={this.props.verifiedPMCursorSourceId}
                        //inconsistentConnectionSourceId={this.props.inconsistentConnectionSourceId}
                        idx={this.props.idx}
                        sourceIndex={this.props.paragraphZip.sourceIds[0]}
                        connectionVerified={this.props.connectionVerified}
                        nextConnectionVerified={this.props.nextConnectionVerified}
                        handleChangeVerified={this.props.handleChangeVerified}
                        handleRematchBelow={this.props.handleRematchBelow}
                        handleParagraphUnion={this.props.handleParagraphUnion}
                        />
                      )
    const nSourceParagraphs = range(this.props.paragraphZip.sourceIds).filter(
      (i) => !this.props.skippedSource.has(i)
    ).length;
    const nTargetParagraphs = range(this.props.paragraphZip.targetIds).filter(
      (i) => !this.props.skippedTarget.has(i)
    ).length;
    const sourcePClasses = (nSourceParagraphs < 2 ) ? "paragraphs" : "paragraphs multipleParagraphs";
    const targetPClasses = (nTargetParagraphs < 2 ) ? "paragraphs" : "paragraphs multipleParagraphs";
    return (<tr>
        <td className={sourcePClasses}>
          {ps_source}
        </td>
          {pz_status}
        <td className={targetPClasses}>
          {ps_target}
        </td></tr>)
    };
}

class ChapterZip extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      connections: props.chapterZip.connections,
      verifiedPMCursorSourceId: props.chapterZip.verifiedPMCursorSourceId,
      unverifiedConnectionSourceIds: new Set(props.chapterZip.unverifiedConnectionSourceIds),
      skippedSource: new Set(props.chapterZip.skippedSource),
      skippedTarget: new Set(props.chapterZip.skippedTarget),
      selectedSource: null,
      selectedTarget: null,
    };
    this.handleParagraphClick = this.handleParagraphClick.bind(this);
    this.handleParagraphUnion = this.handleParagraphUnion.bind(this);
    this.handleParagraphSkip = this.handleParagraphSkip.bind(this);
    this.handleChangeVerified = this.handleChangeVerified.bind(this);
    this.handleRematchBelow = this.handleRematchBelow.bind(this);
  }

  outputData(){
    return JSON.stringify({
      skippedSource: Array.from(this.state.skippedSource),
      skippedTarget: Array.from(this.state.skippedTarget),
      connections: this.state.connections,
      verifiedPMCursorSourceId: this.state.verifiedPMCursorSourceId,
      unverifiedConnectionSourceIds: Array.from(
        this.state.unverifiedConnectionSourceIds)
    })
  }

  handleChangeVerified(pmId){
    const newVerified = (
      this.state.connections.length > pmId ?
      this.state.connections[pmId][0] :
      this.props.chapterZip.paragraphsSource.length
    )
    this.setState({verifiedPMCursorSourceId: newVerified})
  }

  handleRematchBelow(pmId){
    //console.log("Re-match bellow call:", pmId)
  }

  handleParagraphSkip(idx, src){
    if (src === 'source') {
      const skippedSource = new Set(this.state.skippedSource);
      if (skippedSource.has(idx)) {
        skippedSource.delete(idx)
      } else {
        skippedSource.add(idx)
      };
      this.setState({skippedSource: skippedSource})
    } else {
      const skippedTarget = new Set(this.state.skippedTarget);
      if (skippedTarget.has(idx)) {
        skippedTarget.delete(idx)
      } else {
        skippedTarget.add(idx)
      };
      this.setState({skippedTarget: skippedTarget})
    };
  }

  buildParagraphs(){
    // Add bottom of chapterZip
    const connAndBottom = this.state.connections.concat([[
      this.props.chapterZip.paragraphsSource.length,
      this.props.chapterZip.paragraphsTarget.length]])
    const paragraphs = []
    for (let i = 0; i < connAndBottom.length-1; i++){
      const c1 = connAndBottom[i]
      const c2 = connAndBottom[i+1]
      paragraphs.push({sourceIds: [c1[0],c2[0]-1], targetIds: [c1[1],c2[1]-1]})
    };
    return(paragraphs);
  }

  handleParagraphUnion(sInd) {
    const newConnections = this.state.connections.filter((c) => c[0] !== sInd);
    const newUnverifiedConnectionSourceIds = this.state.unverifiedConnectionSourceIds
    newUnverifiedConnectionSourceIds.delete(sInd)

    this.setState({
      connections: newConnections,
      unverifiedConnectionSourceIds: newUnverifiedConnectionSourceIds
    });
  }

  buildNewParagraphZip(sInd, tInd){
    const connectionsBefore = [];
    const connectionsAfter = [];
    const unverifiedConnections = [];
    this.state.connections.forEach((c) => {
      if ((c[0] < sInd) && (c[1] < tInd)) {
        connectionsBefore.push(c)
        if (this.state.unverifiedConnectionSourceIds.has(c[0])) {
          unverifiedConnections.push(c[0])
        }
      } else if ((c[0] > sInd) && (c[1] > tInd)) {
        connectionsAfter.push(c)
        if (this.state.unverifiedConnectionSourceIds.has(c[0])) {
          unverifiedConnections.push(c[0])
        }
      }
    });
    const newConnections = connectionsBefore.concat(
      [[sInd, tInd]],
      connectionsAfter
    );
    this.setState({
      connections: newConnections,
      unverifiedConnectionSourceIds: new Set(unverifiedConnections),
      selectedSource: null,
      selectedTarget: null,
    });
  }

  handleParagraphClick(idx, src){
    let sId, tId
    if (src === 'source') {
      sId = (idx === this.state.selectedSource) ? null : idx;
      tId = this.state.selectedTarget;
      this.setState({selectedSource: sId})
    } else {
      tId = (idx === this.state.selectedTarget) ? null : idx;
      sId = this.state.selectedSource;
      this.setState({selectedTarget: tId})
    }
    if ((sId !== null) && (tId !== null)){
      this.buildNewParagraphZip(sId, tId)
    }
  }

  componentDidMount() {
    const element = document.getElementById('rematch-below');
    const yOffset = -200;
    if (element) {
      const y = element.getBoundingClientRect().top + window.pageYOffset + yOffset;
      window.scrollTo({top: y});
    };
  };

  checkConnectionVerified(idx){
    const con = this.state.connections[idx]
    const aboveCursor = con ? con[0] <= this.state.verifiedPMCursorSourceId : false
    return (con ?
      (aboveCursor || !this.state.unverifiedConnectionSourceIds.has(con[0])
      ) :
      true
    )
  }

  render(){
    const pzs = this.buildParagraphs(this.state.connections).map(
      (pz, idx) => (<ParagraphZip
                      key={idx}
                      idx={idx}
                      paragraphZip={pz}
                      paragraphsSource={this.props.chapterZip.paragraphsSource}
                      paragraphsTarget={this.props.chapterZip.paragraphsTarget}
                      selectedFromSource={this.state.selectedFromSource}
                      selectedFromTarget={this.state.selectedFromTarget}
                      selectedSource={this.state.selectedSource}
                      selectedTarget={this.state.selectedTarget}
                      handleClick={this.handleParagraphClick}
                      handleParagraphUnion={this.handleParagraphUnion}
                      handleParagraphSkip={this.handleParagraphSkip}
                      skippedSource={this.state.skippedSource}
                      skippedTarget={this.state.skippedTarget}
                      verifiedPMCursorSourceId={this.state.verifiedPMCursorSourceId}
                      //inconsistentConnectionSourceId={this.props.chapterZip.inconsistentConnectionSourceId}
                      connectionVerified={this.checkConnectionVerified(idx)}
                      nextConnectionVerified={this.checkConnectionVerified(idx+1)}
                      handleChangeVerified={this.handleChangeVerified}
                      handleRematchBelow={this.handleRematchBelow}
                      />));
    return (
      <div className="chapterzip-editor">
        <input
          type='hidden'
          value={this.outputData()}
          name='chapter_zip[matching_data]'
        />

        <table border={1}>
         <thead>
           <tr>
            <th className="sourceTarget"> Source </th>
            <th> Status </th>
            <th className="sourceTarget"> Target </th>
          </tr>
        </thead>
          <tbody>
            {pzs}
          </tbody>
        </table>
      </div>
    )
  }
}

function range(startEnd) {
    const [startAt, endAt] = startEnd;
    const size = endAt - startAt + 1;
    return [...Array(size).keys()].map(i => i + startAt);
}

const root = ReactDOM.createRoot(document.getElementById('chapterzip-editor'));
root.render(<ChapterZip chapterZip={chapterZip} />);
