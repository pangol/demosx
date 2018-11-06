package seoul.democracy.proposal.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.mysema.query.types.Projections;
import com.mysema.query.types.QBean;
import lombok.Data;
import seoul.democracy.issue.domain.Issue;
import seoul.democracy.issue.domain.IssueFile;
import seoul.democracy.issue.dto.CategoryDto;
import seoul.democracy.issue.dto.IssueStatsDto;
import seoul.democracy.opinion.domain.OpinionType;
import seoul.democracy.proposal.domain.Proposal;
import seoul.democracy.user.dto.UserDto;

import java.time.LocalDateTime;
import java.util.List;

import static seoul.democracy.proposal.domain.QProposal.proposal;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProposalDto {

    public final static QBean<ProposalDto> projection = Projections.fields(ProposalDto.class,
        proposal.id, proposal.createdDate, proposal.modifiedDate,
        UserDto.projectionForBasicByCreatedBy.as("createdBy"),
        UserDto.projectionForBasicByModifiedBy.as("modifiedBy"),
        proposal.createdIp, proposal.modifiedIp, proposal.opinionType,
        CategoryDto.projection.as("category"),
        IssueStatsDto.projection.as("stats"),
        proposal.status, proposal.process,
        proposal.adminCommentDate, proposal.adminComment,
        UserDto.projectionForBasic.as("manager"),
        proposal.managerCommentDate, proposal.managerComment,
        proposal.title, proposal.content);

    public final static QBean<ProposalDto> projectionForAdminList = Projections.fields(ProposalDto.class,
        proposal.id, proposal.createdDate,
        UserDto.projectionForBasicByCreatedBy.as("createdBy"),
        CategoryDto.projection.as("category"),
        IssueStatsDto.projection.as("stats"),
        proposal.status, proposal.process,
        UserDto.projectionForBasic.as("manager"),
        proposal.title);

    private Long id;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDateTime createdDate;
    private LocalDateTime modifiedDate;
    private UserDto createdBy;
    private UserDto modifiedBy;
    private String createdIp;
    private String modifiedIp;
    private OpinionType opinionType;

    private CategoryDto category;

    private IssueStatsDto stats;
    private List<IssueFile> files;

    private Issue.Status status;
    private Proposal.Process process;

    private LocalDateTime adminCommentDate;
    private String adminComment;

    private UserDto manager;
    private LocalDateTime managerCommentDate;
    private String managerComment;

    private String title;
    private String content;
}
